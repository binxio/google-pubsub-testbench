##### permissions #####

resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

##### instance #####

resource "google_cloud_run_service" "data-processor" {
  name     = var.instance-name
  location = var.location

  template {
    spec {
      containers {
        image = var.container-image-uri
      }
      service_account_name = google_service_account.data-processor.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true

  depends_on = [google_project_service.run, google_service_account.data-processor]
}

##### service accounts #####

resource "google_service_account" "data-processor" {
  account_id   = var.instance-name
  display_name = "Data Processor Service Account"
  description  = "Data Processor Service Account"
}
