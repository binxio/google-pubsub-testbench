##### permissions #####

resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

##### ingress access #####

#TODO why does below not work to give unrestricted access?

# resource "google_cloud_run_service_iam_member" "app-forwarder-invoker" {
#   location = google_cloud_run_service.app-forwarder.location
#   # project  = google_cloud_run_service.default.project
#   service    = google_cloud_run_service.app-forwarder.name
#   role       = "roles/run.invoker"
#   member     = "allUsers"
#   depends_on = [google_cloud_run_service.app-forwarder]
# }

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.app-forwarder.location
  project  = google_cloud_run_service.app-forwarder.project
  service  = google_cloud_run_service.app-forwarder.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

##### instance #####

resource "google_cloud_run_service" "app-forwarder" {
  name     = var.instance-name
  location = var.location

  template {
    spec {
      containers {
        image = var.container-image-uri
        env {
          name  = "DATA_PROCESSING_REQUEST_TOPIC_ID"
          value = "data-processing-request-topic"
        }
      }
      service_account_name = google_service_account.app-forwarder.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true

  depends_on = [google_project_service.run, google_service_account.app-forwarder]
}

##### egress (service accounts) #####

resource "google_service_account" "app-forwarder" {
  account_id   = var.instance-name
  display_name = "App Forwarder Service Account"
  description  = "App Forwarder Service Account"
}
