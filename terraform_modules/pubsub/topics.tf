##### permissions #####

resource "google_project_service" "pubsub-service" {
  project            = var.project-id
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}

#                                          #
#####          data-processing-request topic           #####
#                                          #

resource "google_pubsub_topic" "data-processing-request-topic" {
  name       = "data-processing-request-topic"
  project    = var.project-id
  depends_on = [google_project_service.pubsub-service]
}

# publishers #

resource "google_pubsub_topic_iam_member" "data-processing-request-publisher" {
  member     = "serviceAccount:${var.app-forwarder-email}"
  topic      = google_pubsub_topic.data-processing-request-topic.id
  role       = "roles/pubsub.publisher"
  depends_on = [google_pubsub_topic.data-processing-request-topic]
}

# push subscription, its service account, and permission to invoke Cloud Run #
# resource "google_service_account" "data-processing-request-subscription" {
#   account_id   = "data-proc-req-subscription"
#   display_name = "Service Account of the data processing request subscription"
# }

# resource "google_cloud_run_service_iam_member" "data-processor-invoker" {
#   location = var.location
#   service  = var.app-forwarder-name
#   # member   = "serviceAccount:data-proc-req-subscription@speeltuin-teindevries.iam.gserviceaccount.com"
#   member = "serviceAccount:${google_service_account.data-processing-request-subscription.email}" #TODO add prefix
#   # role       = "roles/run.invoker"
#   role       = "roles/iam.serviceAccountTokenCreator"
#   depends_on = [google_service_account.data-processing-request-subscription]
# }


resource "google_pubsub_subscription" "data-processing-request-subscription" {
  name    = "data-processing-request-subscription"
  topic   = google_pubsub_topic.data-processing-request-topic.id
  project = var.project-id

  push_config {
    # oidc_token {
    #   service_account_email = google_service_account.data-processing-request-subscription.email
    # }
    push_endpoint = var.data-processor-url
  }

  depends_on = [google_pubsub_topic.data-processing-request-topic]
}


#                                          #
#####          response topic          #####
#                                          #


resource "google_pubsub_topic" "data-processing-response-topic" {
  name       = "data-processing-response-topic"
  project    = var.project-id
  depends_on = [google_project_service.pubsub-service]
}

# publishers #

resource "google_pubsub_topic_iam_member" "response-publisher" {
  member = "serviceAccount:${var.data-processor-email}"
  topic  = google_pubsub_topic.data-processing-response-topic.id
  role   = "roles/pubsub.publisher"
  # depends_on = [google_pubsub_topic.data-processing-response-topic]
}

# subscriptions and their subscribers #

resource "google_pubsub_subscription" "data-processing-response-subscription" {
  name    = "data-processing-response-subscription"
  topic   = google_pubsub_topic.data-processing-response-topic.id
  project = var.project-id
  # depends_on = [google_pubsub_topic.response-topic]
}

resource "google_pubsub_subscription_iam_member" "data-processing-response-subscriber" {
  subscription = google_pubsub_subscription.data-processing-response-subscription.name
  role         = "roles/pubsub.subscriber"
  member       = "user:${var.user-account}"
  # depends_on   = [google_pubsub_subscription.data-processing-response-subscription]
}












### subscription

# resource "google_service_account" "pubsub" {
#   account_id   = "pubsub"
#   display_name = "Pub/Sub Service Account"
#   description  = "Pub/Sub Service Account"
# }

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

#####


# resource "google_pubsub_subscription_iam_member" "data-processing-request-subscriber" {
#   subscription = google_pubsub_subscription.data-processing-request-subscription.name
#   role         = "roles/pubsub.subscriber"
#   member       = "serviceAccount:${var.data-processor-email}"
#   depends_on   = [google_pubsub_subscription.response-subscription]
# }

# resource "google_pubsub_subscription_iam_member" "data-processing-request-pusher" {
#   subscription = google_pubsub_subscription.data-processing-request-subscription.name
#   role         = "roles/run.invoker"
#   member       = "serviceAccount:${var.data-processor-email}"
# }

# resource "google_cloud_run_service_iam_member" "app-forwarder-invoker" {
#   location = google_cloud_run_service.app-forwarder.location
#   service    = google_cloud_run_service.app-forwarder.name
#   role       = "roles/run.invoker"
#   member     = google_pubsub_subscription.XXX
#   depends_on =
# }
