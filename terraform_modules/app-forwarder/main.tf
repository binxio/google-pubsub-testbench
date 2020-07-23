##### instance #####

resource "google_cloud_run_service" "app-forwarder" {
  name     = var.instance-name
  location = var.location

  template {
    spec {
      containers {
        image = var.container-image-uri
      }
      service_account_name = google_service_account.app-forwarder.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  depends_on = [google_project_service.run, google_service_account.app-forwarder]
}


##### permissions #####
resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "app-forwarder" {
  account_id   = var.instance-name
  display_name = "Cloud Run Api Service Account"
  description  = "Cloud Run Api Service Account"
  # depends_on   = [google_cloud_run_service.app-forwarder]
}
#
# resource "google_service_account_iam_member" "app-forwarder" {
#   service_account_id = "app-forwarder"
#   role               = "roles/iam.serviceAccountUser"
#   member             = "serviceAccount:${google_service_account.app-forwarder.email}"
#   depends_on         = [google_service_account.app-forwarder]
# }
