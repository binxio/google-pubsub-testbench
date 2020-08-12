output "email" {
  value = google_service_account.data-processor.email
}

output "url" {
  value = google_cloud_run_service.data-processor.status[0].url
}
