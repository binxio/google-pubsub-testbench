##### topics ######

# make for multiple based on list in variables
resource "google_pubsub_topic" "topic" {
  name       = var.topic["name"]
  project    = var.project-id
  depends_on = [google_project_service.pubsub-service]
}


##### publishers #####
# would it be better to make policies out of these?
resource "google_pubsub_topic_iam_member" "publisher" {
  #TODO replace below with service account of Cloud Run
  member     = "serviceAccount:${var.api-email}"
  topic      = "projects/${var.project-id}/topics/${var.topic["name"]}"
  role       = "roles/pubsub.publisher"
  depends_on = [google_pubsub_topic.topic]
  # # for multiple:
  # count      = length(var.topic["publisher"])
  # member     = "serviceAccount:${element(var.topic["publisher"], count.index)}@${var.project-id}.iam.gserviceaccount.com"
}


##### subscriptions #####

resource "google_pubsub_subscription_iam_binding" "subscriber" {
  subscription = google_pubsub_subscription.subscription.name
  members = [
    "serviceAccount:${var.data-processor-email}"
  ]
  role       = "roles/pubsub.subscriber"
  depends_on = [google_pubsub_subscription.subscription]
  # # for multiple:
  # subscription = google_pubsub_subscription.subscription[count.index].name
  # count        = length(google_pubsub_subscription.subscription)
  # members      = [for _, subscriber in var.topic["subscriptions"][google_pubsub_subscription.subscription[count.index].name] : "serviceAccount:${subscriber}@${var.project-id}.iam.gserviceaccount.com"]
}

resource "google_pubsub_subscription" "subscription" {
  name       = "request-subscription"
  topic      = "projects/${var.project-id}/topics/${var.topic["name"]}"
  project    = var.project-id
  depends_on = [google_pubsub_topic.topic]
  # # for multiple:
  # count = length(keys(var.topic["subscriptions"]))
  # name  = element(keys(var.topic["subscriptions"]), count.index)
}
