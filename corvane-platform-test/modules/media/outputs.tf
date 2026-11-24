output "archive_bucket" {
  value = google_storage_bucket.archive.name
}

output "ingest_url" {
  value = google_cloud_run_v2_service.ingest.uri
}
