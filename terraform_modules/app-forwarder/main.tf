##### permissions #####

resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

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

##### service accounts #####

resource "google_service_account" "app-forwarder" {
  account_id   = var.instance-name
  display_name = "App Forwarder Service Account"
  description  = "App Forwarder Service Account"
}
