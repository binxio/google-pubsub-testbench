data "google_iam_policy" "admin" {
  binding {
    role = "roles/editor"
    members = [
      "serviceAccount:pubsub-testbench@pubsub-testbench.iam.gserviceaccount.com",
    ]
  }
}

# resource "google_pubsub_subscription_iam_policy" "editor" {
#   subscription = "subscription-1"
#   policy_data  = data.google_iam_policy.admin.policy_data
# }

resource "google_project_service" "pubsub-service" {
  project = var.project-id
  service = "pubsub.googleapis.com"
}

resource "google_pubsub_topic" "topic" {
  name       = var.topic["name"]
  project    = var.project-id
  depends_on = [google_project_service.pubsub-service]
}

resource "google_pubsub_subscription" "subscription" {
  count      = length(keys(var.topic["subscriptions"]))
  name       = element(keys(var.topic["subscriptions"]), count.index)
  topic      = "projects/${var.project-id}/topics/${var.topic["name"]}"
  project    = var.project-id
  depends_on = [google_pubsub_topic.topic]
}

resource "google_pubsub_subscription_iam_binding" "subscriber" {
  count        = length(google_pubsub_subscription.subscription)
  members      = [for _, subscriber in var.topic["subscriptions"][google_pubsub_subscription.subscription[count.index].name] : "serviceAccount:${subscriber}@${var.project-id}.iam.gserviceaccount.com"]
  subscription = google_pubsub_subscription.subscription[count.index].name
  role         = "roles/pubsub.subscriber"
  depends_on   = [google_pubsub_subscription.subscription]
}

# resource "google_pubsub_topic_iam_member" "publisher" {
#   # count      = length(var.topic["publisher"])
#   member     = "serviceAccount:${element(var.topic["publisher"], count.index)}@${var.project-id}.iam.gserviceaccount.com"
#   topic      = "projects/${var.project-id}/topics/${var.topic["name"]}"
#   role       = "roles/pubsub.publisher"
#   depends_on = [google_pubsub_topic.topic]
# }
