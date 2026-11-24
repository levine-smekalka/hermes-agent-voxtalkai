# Scheduled pull of one client's site and contact data into the core
# database.
resource "google_cloud_run_v2_job" "this" {
  project             = var.project_id
  name                = "client-sync-${var.client}"
  location            = var.region
  deletion_protection = false

  template {
    template {
      service_account = var.service_account_email
      timeout         = var.timeout
      max_retries     = 0

      containers {
        image = var.image

        env {
          name  = "CLIENT_ID"
          value = var.client
        }

        env {
          name  = "WRITE_ENABLED"
          value = tostring(var.write_enabled)
        }

        resources {
          limits = {
            cpu    = "1"
            memory = var.memory
          }
        }
      }
    }
  }
}

resource "google_cloud_scheduler_job" "this" {
  project   = var.project_id
  name      = "client-sync-${var.client}"
  region    = var.region
  schedule  = var.schedule
  time_zone = "Etc/UTC"
  paused    = var.paused

  http_target {
    http_method = "POST"
    uri         = "https://run.googleapis.com/v2/projects/${var.project_id}/locations/${var.region}/jobs/${google_cloud_run_v2_job.this.name}:run"

    oauth_token {
      service_account_email = var.scheduler_service_account_email
    }
  }
}
