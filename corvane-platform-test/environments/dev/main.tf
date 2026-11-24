locals {
  image_repo = "${var.region}-docker.pkg.dev/${var.project_id}/apps"
}

module "network" {
  source = "../../modules/network"

  project_id = var.project_id
  region     = var.region
  name       = "corvane-dev"
  cidr       = "10.110.0.0/20"

  firewall_rules = {
    "automation-https" = {
      name          = "automation-engine-https"
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["automation-engine"]
      protocol      = "tcp"
      ports         = ["443"]
    }
    "sip-tls" = {
      name          = "sip-edge-sip-tls"
      source_ranges = ["198.51.100.0/24"]
      target_tags   = ["sip-edge"]
      protocol      = "tcp"
      ports         = ["5061"]
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

  project_id              = var.project_id
  region                  = var.region
  zone                    = var.zone
  machine_type            = "e2-standard-2"
  disk_gb                 = 50
  subnet_id               = module.network.subnet_id
  service_account_email   = google_service_account.automation_engine.email
  snapshot_retention_days = 3

  labels = {
    env     = "dev"
    service = "automation-engine"
  }
}

module "sip_edge" {
  source = "../../modules/sip_edge"

  project_id            = var.project_id
  region                = var.region
  zones                 = [var.zone]
  instance_count        = 1
  subnet_id             = module.network.subnet_id
  service_account_email = google_service_account.automation_engine.email
}

module "core_db" {
  source = "../../modules/core_db"

  project_id   = var.project_id
  region       = var.region
  tier         = "db-custom-1-3840"
  app_password = var.db_app_password
}

module "media" {
  source = "../../modules/media"

  project_id            = var.project_id
  region                = var.region
  retention_days        = 7
  service_account_email = google_service_account.automation_engine.email
  image_repo            = local.image_repo
  ingest_version        = "1.43.0-rc1"
  analysis_version      = "0.19.0-rc2"
}

resource "google_service_account" "automation_engine" {
  project      = var.project_id
  account_id   = "automation-engine"
  display_name = "Automation engine (dev)"
}
