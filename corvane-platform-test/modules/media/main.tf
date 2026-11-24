# Video pipeline: clients push camera clips to media-ingest, clips land in the
# archive bucket, and frame-analysis scores them.
resource "google_storage_bucket" "archive" {
  project                     = var.project_id
  name                        = "${var.project_id}-media-archive"
  location                    = var.location
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = false
  }

  lifecycle_rule {
    condition {
      age = var.retention_days
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket_iam_member" "service" {
  bucket = google_storage_bucket.archive.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.service_account_email}"
}

resource "google_cloud_run_v2_service" "ingest" {
  project             = var.project_id
  name                = "media-ingest"
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

  template {
    service_account                  = var.service_account_email
    max_instance_request_concurrency = 20

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      image = "${var.image_repo}/media-ingest:${var.ingest_version}"

      env {
        name  = "ARCHIVE_BUCKET"
        value = google_storage_bucket.archive.name
      }

      resources {
        limits = {
          cpu    = "2"
          memory = "2Gi"
        }
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "ingest_invokers" {
  for_each = toset(var.ingest_invokers)

  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.ingest.name
  role     = "roles/run.invoker"
  member   = each.value
}

resource "google_cloud_run_v2_job" "frame_analysis" {
  project             = var.project_id
  name                = "frame-analysis"
  location            = var.region
  deletion_protection = false

  template {
    task_count  = 1
    parallelism = 1

    template {
      service_account = var.service_account_email
      timeout         = "1800s"
      max_retries     = 1

      containers {
        image = "${var.image_repo}/frame-analysis:${var.analysis_version}"

        env {
          name  = "ARCHIVE_BUCKET"
          value = google_storage_bucket.archive.name
        }

        resources {
          limits = {
            cpu    = "4"
            memory = "8Gi"
          }
        }
      }
    }
  }
}
