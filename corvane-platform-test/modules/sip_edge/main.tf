# SIP border controllers between the telephony carriers and the voice agent
# platform, behind a regional network load balancer.
resource "google_compute_address" "this" {
  project = var.project_id
  name    = "${var.name}-ip"
  region  = var.region
}

resource "google_compute_instance" "this" {
  count = var.instance_count

  project      = var.project_id
  name         = "${var.name}-${count.index + 1}"
  zone         = var.zones[count.index % length(var.zones)]
  machine_type = var.machine_type
  tags         = ["sip-edge"]
  labels       = var.labels

  boot_disk {
    initialize_params {
      image = var.image
      size  = 40
    }
  }

  network_interface {
    subnetwork = var.subnet_id
    access_config {}
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    # Carrier onboarding writes per-trunk settings into instance metadata.
    ignore_changes = [metadata]
  }
}

resource "google_compute_http_health_check" "this" {
  project      = var.project_id
  name         = "${var.name}-hc"
  port         = 8080
  request_path = "/health"
}

resource "google_compute_target_pool" "this" {
  project       = var.project_id
  name          = "${var.name}-pool"
  region        = var.region
  instances     = [for i in google_compute_instance.this : "${i.zone}/${i.name}"]
  health_checks = [google_compute_http_health_check.this.name]
}

resource "google_compute_forwarding_rule" "sip_tls" {
  project     = var.project_id
  name        = "${var.name}-sip-tls"
  region      = var.region
  ip_address  = google_compute_address.this.address
  ip_protocol = "TCP"
  port_range  = "5061"
  target      = google_compute_target_pool.this.id
}

resource "google_compute_forwarding_rule" "rtp" {
  project     = var.project_id
  name        = "${var.name}-rtp"
  region      = var.region
  ip_address  = google_compute_address.this.address
  ip_protocol = "UDP"
  port_range  = "10000-20000"
  target      = google_compute_target_pool.this.id
}
