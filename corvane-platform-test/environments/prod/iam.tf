resource "google_service_account" "automation_engine" {
  project      = var.project_id
  account_id   = "automation-engine"
  display_name = "Automation engine"
}

resource "google_service_account" "sip_edge" {
  project      = var.project_id
  account_id   = "sip-edge"
  display_name = "SIP edge"
}

resource "google_service_account" "media" {
  project      = var.project_id
  account_id   = "media-pipeline"
  display_name = "Media ingest and analysis"
}

resource "google_service_account" "client_sync" {
  project      = var.project_id
  account_id   = "client-sync"
  display_name = "Client sync jobs"
}

resource "google_service_account" "scheduler" {
  project      = var.project_id
  account_id   = "client-sync-scheduler"
  display_name = "Client sync scheduler"
}

locals {
  project_roles = {
    "automation-engine-logs"    = { role = "roles/logging.logWriter", member = google_service_account.automation_engine.member }
    "automation-engine-metrics" = { role = "roles/monitoring.metricWriter", member = google_service_account.automation_engine.member }
    "automation-engine-sql"     = { role = "roles/cloudsql.client", member = google_service_account.automation_engine.member }
    "sip-edge-logs"             = { role = "roles/logging.logWriter", member = google_service_account.sip_edge.member }
    "sip-edge-metrics"          = { role = "roles/monitoring.metricWriter", member = google_service_account.sip_edge.member }
    "client-sync-sql"           = { role = "roles/cloudsql.client", member = google_service_account.client_sync.member }
    "scheduler-invoker"         = { role = "roles/run.invoker", member = google_service_account.scheduler.member }
    "platform-admins-owner"     = { role = "roles/owner", member = "group:platform-admins@corvane.example" }
    "engineers-viewer"          = { role = "roles/viewer", member = "group:engineering@corvane.example" }
  }
}

resource "google_project_iam_member" "this" {
  for_each = local.project_roles

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}
