# Self-hosted workflow engine. Receives webhooks from clients and voice
# providers and orchestrates calls, media analysis and client notifications.
resource "google_compute_address" "this" {
  project = var.project_id
  name    = "${var.name}-ip"
  region  = var.region
}

# The static IP is attached to the instance, so it is used both for inbound
# webhooks and as the source address of every outbound call the engine makes.
resource "google_compute_instance" "this" {
  project                   = var.project_id
  name                      = var.name
  zone                      = var.zone
  machine_type              = var.machine_type
  tags                      = ["automation-engine"]
  labels                    = var.labels
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = var.disk_gb
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = var.subnet_id
    access_config {
      nat_ip = google_compute_address.this.address
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot = true
  }
}

resource "google_compute_resource_policy" "snapshots" {
  project = var.project_id
  name    = "${var.name}-daily"
  region  = var.region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "03:00"
      }
    }
    retention_policy {
      max_retention_days = var.snapshot_retention_days
    }
  }
}

resource "google_compute_disk_resource_policy_attachment" "snapshots" {
  project = var.project_id
  name    = google_compute_resource_policy.snapshots.name
  disk    = google_compute_instance.this.name
  zone    = var.zone
}
