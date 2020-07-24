##### permissions #####

resource "google_project_service" "pubsub-service" {
  project            = var.project-id
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}

##### service account #####

resource "google_service_account" "pubsub" {
  account_id   = "pubsub"
  display_name = "Pub/Sub Service Account"
  description  = "Pub/Sub Service Account"
}

# resource "google_service_account_iam_member" "admin-account-iam" {
#   service_account_id = google_service_account.pubsub.name
#   role               = "roles/run.invoker"
#   member             = "serviceAccount:${google_service_account.pubsub.email}"
# }

# resource "google_cloud_run_service_iam_member" "member" {
#   location = google_cloud_run_service.default.location
#   project  = google_cloud_run_service.default.project
#   service  = google_cloud_run_service.default.name
#   role     = "roles/viewer"
#   member   = "user:jane@example.com"
# }


#                                          #
#####          request topic           #####
#                                          #


resource "google_pubsub_topic" "request-topic" {
  name       = "request-topic"
  project    = var.project-id
  depends_on = [google_project_service.pubsub-service]
}

# publishers #

resource "google_pubsub_topic_iam_member" "request-publisher" {
  member     = "serviceAccount:${var.app-forwarder-email}"
  topic      = google_pubsub_topic.request-topic.id
  role       = "roles/pubsub.publisher"
  depends_on = [google_pubsub_topic.request-topic]
}

# subscriptions #

resource "google_pubsub_subscription" "request-subscription" {
  name       = "request-subscription"
  topic      = google_pubsub_topic.request-topic.id
  project    = var.project-id
  depends_on = [google_pubsub_topic.request-topic]
}

resource "google_pubsub_subscription_iam_member" "request-subscriber" {
  subscription = google_pubsub_subscription.request-subscription.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${var.data-processor-email}"
  depends_on   = [google_pubsub_topic.request-topic]
}


#                                          #
#####          response topic          #####
#                                          #


resource "google_pubsub_topic" "response-topic" {
  name       = "response-topic"
  project    = var.project-id
  depends_on = [google_project_service.pubsub-service]
}

# publishers #

resource "google_pubsub_topic_iam_member" "response-publisher" {
  member     = "serviceAccount:${var.data-processor-email}"
  topic      = google_pubsub_topic.response-topic.id
  role       = "roles/pubsub.publisher"
  depends_on = [google_pubsub_topic.response-topic]
}
