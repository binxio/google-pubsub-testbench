package main

import (
	"context"
	"os"
	"cloud.google.com/go/pubsub"
)

func handle(e error) {
	// minimal error handler
	if e != nil {
		panic(e)
	}
}

func main() {
	// load context
	ctx := context.Background()
	projectID := os.Getenv("PROJECT_ID")
	data_processing_request_topic_id := os.Getenv("DATA_PROCESSING_REQUEST_TOPIC_ID")
	data_processing_response_topic_id := os.Getenv("DATA_PROCESSING_RESPONSE_TOPIC_ID")
	data_processing_request_push_subscription_uri := os.Getenv("DATA_PROCESSING_REQUEST_PUSH_SUBSCRIPTION_URI")

	// connect to pubsub service
	client, err := pubsub.NewClient(ctx, projectID); handle(err)

	// make topic for data processing request
	request_topic, err := client.CreateTopic(ctx, data_processing_request_topic_id + "-topic"); handle(err)
	defer request_topic.Stop()

	// subscribe (via push) the data-processor to that topic
	_, err = client.CreateSubscription(ctx, data_processing_request_topic_id + "-subscription", pubsub.SubscriptionConfig{
		Topic: request_topic,
		PushConfig: pubsub.PushConfig{
			Endpoint: data_processing_request_push_subscription_uri,
		},
	})
	handle(err)

	// make topic for data processing responses
	response_topic, err := client.CreateTopic(ctx, data_processing_response_topic_id + "-topic"); handle(err)
	defer response_topic.Stop()
}
