##### instance #####

resource "google_cloud_run_service" "api" {
  name     = var.instance-name
  location = var.location

  template {
    spec {
      containers {
        image = var.container-image-uri
      }
      service_account_name = google_service_account.api.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  depends_on = [google_project_service.run, google_service_account.api]
}


##### permissions #####
resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "api" {
  account_id   = var.instance-name
  display_name = "Cloud Run Api Service Account"
  description  = "Cloud Run Api Service Account"
  # depends_on   = [google_cloud_run_service.api]
}
#
# resource "google_service_account_iam_member" "api" {
#   service_account_id = "api"
#   role               = "roles/iam.serviceAccountUser"
#   member             = "serviceAccount:${google_service_account.api.email}"
#   depends_on         = [google_service_account.api]
# }
