resource "google_secret_manager_secret" "db_app_password" {
  project   = var.project_id
  secret_id = "core-db-app-password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_app_password" {
  secret      = google_secret_manager_secret.db_app_password.id
  secret_data = var.db_app_password
}

resource "google_secret_manager_secret_iam_member" "db_app_password" {
  for_each = {
    automation-engine = google_service_account.automation_engine.member
    client-sync       = google_service_account.client_sync.member
  }

  project   = var.project_id
  secret_id = google_secret_manager_secret.db_app_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value
}
