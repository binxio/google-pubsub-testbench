##### permissions #####

resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

#TODO remove: temporarily set permission to all
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.data-processor.location
  project  = google_cloud_run_service.data-processor.project
  service  = google_cloud_run_service.data-processor.name

  policy_data = data.google_iam_policy.noauth.policy_data
}


##### instance #####

resource "google_cloud_run_service" "data-processor" {
  name     = var.instance-name
  location = var.location

  template {
    spec {
      containers {
        image = var.container-image-uri
        env {
          name  = "DATA_PROCESSING_RESPONSE_TOPIC_ID"
          value = "data-processing-response"
        }
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
