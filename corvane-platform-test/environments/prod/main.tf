locals {
  image_repo = "${var.region}-docker.pkg.dev/${var.project_id}/apps"

  carrier_ranges = ["198.51.100.0/24", "203.0.113.0/25"]

  health_check_ranges = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]

  vpn_clients = {
    northgate = {
      peer_ip     = "45.83.120.10"
      peer_ranges = ["10.40.0.0/24", "10.40.1.0/24"]
    }
    westmere = {
      peer_ip     = "45.83.121.22"
      peer_ranges = ["172.20.8.0/24"]
    }
  }

  sync_clients = {
    northgate = { schedule = "0 1 * * *", write_enabled = true }
    westmere  = { schedule = "30 2 * * *", write_enabled = true }
    hollins   = { schedule = "15 4 * * *", write_enabled = true }
  }
}

module "network" {
  source = "../../modules/network"

  project_id = var.project_id
  region     = var.region
  name       = "corvane-prod"
  cidr       = "10.10.0.0/20"

  firewall_rules = {
    "automation-https" = {
      name          = "automation-engine-https"
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["automation-engine"]
      protocol      = "tcp"
      ports         = ["443"]
      log           = true
    }
    "sip-tls" = {
      name          = "sip-edge-sip-tls"
      source_ranges = local.carrier_ranges
      target_tags   = ["sip-edge"]
      protocol      = "tcp"
      ports         = ["5061"]
    }
    "sip-rtp" = {
      name          = "sip-edge-rtp"
      source_ranges = local.carrier_ranges
      target_tags   = ["sip-edge"]
      protocol      = "udp"
      ports         = ["10000-20000"]
    }
    "health-checks" = {
      name          = "allow-lb-health-checks"
      source_ranges = local.health_check_ranges
      target_tags   = ["sip-edge"]
      protocol      = "tcp"
      ports         = ["8080"]
    }
    "iap-ssh" = {
      name          = "allow-iap-ssh"
      source_ranges = ["35.235.240.0/20"]
      protocol      = "tcp"
      ports         = ["22"]
    }
  }
}

module "automation_engine" {
  source = "../../modules/automation_engine"

  project_id            = var.project_id
  region                = var.region
  zone                  = var.zone
  machine_type          = "e2-standard-4"
  subnet_id             = module.network.subnet_id
  service_account_email = google_service_account.automation_engine.email

  labels = {
    env     = "prod"
    service = "automation-engine"
  }
}

module "sip_edge" {
  source = "../../modules/sip_edge"

  project_id            = var.project_id
  region                = var.region
  zones                 = ["${var.region}-a", "${var.region}-b"]
  subnet_id             = module.network.subnet_id
  service_account_email = google_service_account.sip_edge.email

  labels = {
    env     = "prod"
    service = "sip-edge"
  }
}

module "core_db" {
  source = "../../modules/core_db"

  project_id        = var.project_id
  region            = var.region
  tier              = "db-custom-2-8192"
  availability_type = "REGIONAL"
  pitr_enabled      = true
  app_password      = var.db_app_password
}

module "media" {
  source = "../../modules/media"

  project_id            = var.project_id
  region                = var.region
  retention_days        = 30
  service_account_email = google_service_account.media.email
  image_repo            = local.image_repo
  ingest_version        = "1.42.3"
  analysis_version      = "0.18.0"
  min_instances         = 1
  max_instances         = 40

  ingest_invokers = [
    "serviceAccount:${google_service_account.automation_engine.email}",
  ]
}

module "vpn" {
  source   = "../../modules/client_vpn"
  for_each = local.vpn_clients

  project_id    = var.project_id
  region        = var.region
  client        = each.key
  network_id    = module.network.network_id
  peer_ip       = each.value.peer_ip
  local_cidr    = "10.10.0.0/20"
  peer_ranges   = each.value.peer_ranges
  shared_secret = var.vpn_shared_secrets[each.key]
}

module "client_sync" {
  source   = "../../modules/client_sync"
  for_each = local.sync_clients

  project_id                      = var.project_id
  region                          = var.region
  client                          = each.key
  image                           = "${local.image_repo}/client-sync:2.7.1"
  schedule                        = each.value.schedule
  write_enabled                   = each.value.write_enabled
  service_account_email           = google_service_account.client_sync.email
  scheduler_service_account_email = google_service_account.scheduler.email
}
