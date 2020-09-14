# permissions #
resource "google_project_service" "pubsub-service" {
  project            = var.project-id
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}

# service account with which to push subscriptions #

# resource "google_service_account" "pubsub" {
#   account_id   = "pubsub"
#   display_name = "Pub/Sub Service Account"
#   description  = "Pub/Sub Service Account"
# }
#
# resource "google_service_account_iam_member" "admin-account-iam" {
#   service_account_id = google_service_account.pubsub.name
#   role               = "roles/run.invoker"
#   member             = "serviceAccount:${google_service_account.pubsub.email}"
# }




#####          data processing request topic           #####
#                                                          #

# make topic #
resource "google_pubsub_topic" "data-processing-request-topic" {
  name       = "data-processing-request-topic"
  project    = var.project-id
  depends_on = [google_project_service.pubsub-service]
}

# set app-forwarder as publisher #
resource "google_pubsub_topic_iam_member" "data-processing-request-publisher" {
  member     = "serviceAccount:${var.app-forwarder-email}"
  topic      = google_pubsub_topic.data-processing-request-topic.id
  role       = "roles/pubsub.publisher"
  depends_on = [google_pubsub_topic.data-processing-request-topic]
}

# make a push subscription to data-processor #
resource "google_pubsub_subscription" "data-processing-request-subscription" {
  name    = "data-processing-request-subscription"
  topic   = google_pubsub_topic.data-processing-request-topic.id
  project = var.project-id

  push_config {
    push_endpoint = var.data-processor-url
  }

  depends_on = [google_pubsub_topic.data-processing-request-topic]
}




#####          data processing response topic          #####
#                                                          #

# make topic #
resource "google_pubsub_topic" "data-processing-response-topic" {
  name       = "data-processing-response-topic"
  project    = var.project-id
  depends_on = [google_project_service.pubsub-service]
}

# set data processor as publisher #
resource "google_pubsub_topic_iam_member" "response-publisher" {
  member = "serviceAccount:${var.data-processor-email}"
  topic  = google_pubsub_topic.data-processing-response-topic.id
  role   = "roles/pubsub.publisher"
}

# make a pull subscription to the topic #
resource "google_pubsub_subscription" "data-processing-response-subscription" {
  name    = "data-processing-response-subscription"
  topic   = google_pubsub_topic.data-processing-response-topic.id
  project = var.project-id
}

# allow the user-account to pull messages #
resource "google_pubsub_subscription_iam_member" "data-processing-response-subscriber" {
  subscription = google_pubsub_subscription.data-processing-response-subscription.name
  role         = "roles/pubsub.subscriber"
  member       = "user:${var.user-account}"
}
