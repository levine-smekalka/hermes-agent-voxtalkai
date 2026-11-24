# Site-to-site IPsec tunnel to one client's on-premises firewall. The client
# reaches the automation engine over the tunnel instead of the internet.
resource "google_compute_address" "this" {
  project = var.project_id
  name    = "vpn-${var.client}-ip"
  region  = var.region
}

resource "google_compute_vpn_gateway" "this" {
  project = var.project_id
  name    = "vpn-${var.client}"
  region  = var.region
  network = var.network_id
}

resource "google_compute_forwarding_rule" "esp" {
  project     = var.project_id
  name        = "vpn-${var.client}-esp"
  region      = var.region
  ip_protocol = "ESP"
  ip_address  = google_compute_address.this.address
  target      = google_compute_vpn_gateway.this.id
}

resource "google_compute_forwarding_rule" "udp500" {
  project     = var.project_id
  name        = "vpn-${var.client}-udp500"
  region      = var.region
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.this.address
  target      = google_compute_vpn_gateway.this.id
}

resource "google_compute_forwarding_rule" "udp4500" {
  project     = var.project_id
  name        = "vpn-${var.client}-udp4500"
  region      = var.region
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.this.address
  target      = google_compute_vpn_gateway.this.id
}

resource "google_compute_vpn_tunnel" "this" {
  project                 = var.project_id
  name                    = "vpn-${var.client}"
  region                  = var.region
  target_vpn_gateway      = google_compute_vpn_gateway.this.id
  peer_ip                 = var.peer_ip
  shared_secret           = var.shared_secret
  ike_version             = 2
  local_traffic_selector  = [var.local_cidr]
  remote_traffic_selector = var.peer_ranges

  depends_on = [
    google_compute_forwarding_rule.esp,
    google_compute_forwarding_rule.udp500,
    google_compute_forwarding_rule.udp4500,
  ]
}

resource "google_compute_route" "this" {
  for_each = toset(var.peer_ranges)

  project             = var.project_id
  name                = "vpn-${var.client}-${replace(replace(each.value, ".", "-"), "/", "-")}"
  network             = var.network_id
  dest_range          = each.value
  priority            = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.this.id
}

resource "google_compute_firewall" "from_client" {
  project       = var.project_id
  name          = "vpn-${var.client}-ingress"
  network       = var.network_id
  direction     = "INGRESS"
  source_ranges = var.peer_ranges
  target_tags   = ["automation-engine"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}
