package main

import (
	"context"
	"os"
	"cloud.google.com/go/pubsub"
)

func handle(e error) {
	if e != nil {
		panic(e)
	}
}

func main() {

	ctx := context.Background()
	project := os.Getenv("PROJECT_ID")

	client, err := pubsub.NewClient(ctx, project); handle(err)

	data_processing_request_topic_id := os.Getenv("DATA_PROCESSING_REQUEST_TOPIC_ID")
	request_topic, err := client.CreateTopic(ctx, data_processing_request_topic_id + "-topic"); handle(err)
	defer request_topic.Stop()

	data_processing_response_topic_id := os.Getenv("DATA_PROCESSING_RESPONSE_TOPIC_ID")
	response_topic, err := client.CreateTopic(ctx, data_processing_response_topic_id + "-topic"); handle(err)
	defer response_topic.Stop()

	data_processing_request_push_subscription_uri := os.Getenv("DATA_PROCESSING_REQUEST_PUSH_SUBSCRIPTION_URI")
	_, err = client.CreateSubscription(ctx, data_processing_request_topic_id + "-subscription", pubsub.SubscriptionConfig{
		Topic: request_topic,
		PushConfig: pubsub.PushConfig{
			Endpoint: data_processing_request_push_subscription_uri,
		},
	})
	handle(err)
}
