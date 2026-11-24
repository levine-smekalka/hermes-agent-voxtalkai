resource "google_sql_database_instance" "this" {
  project             = var.project_id
  name                = var.name
  region              = var.region
  database_version    = "POSTGRES_15"
  deletion_protection = true

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_autoresize   = true

    ip_configuration {
      ipv4_enabled = true
      ssl_mode     = "ENCRYPTED_ONLY"

      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.key
          value = authorized_networks.value
        }
      }
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = var.pitr_enabled
      start_time                     = "02:00"
    }

    maintenance_window {
      day  = 7
      hour = 3
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }
  }

  lifecycle {
    # Authorised networks are granted by the data team during client migrations.
    ignore_changes = [settings[0].ip_configuration[0].authorized_networks]
  }
}

resource "google_sql_database" "app" {
  project  = var.project_id
  name     = "corvane"
  instance = google_sql_database_instance.this.name
}

resource "google_sql_user" "app" {
  project  = var.project_id
  name     = "corvane_app"
  instance = google_sql_database_instance.this.name
  password = var.app_password
}
