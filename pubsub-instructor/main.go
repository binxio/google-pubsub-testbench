package main

import (
	"cloud.google.com/go/pubsub"
	"context"
	"os"
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

	// connect to pubsub service
	client, err := pubsub.NewClient(ctx, os.Getenv("PROJECT_ID"))
	handle(err)

	// make topic for data processing request
	request_topic, err := client.CreateTopic(ctx, os.Getenv("DATA_PROCESSING_REQUEST_TOPIC"))
	handle(err)
	defer request_topic.Stop()

	// subscribe (via push) the data-processor to that topic
	_, err = client.CreateSubscription(ctx, os.Getenv("DATA_PROCESSING_REQUEST_SUBSCRIPTION"), pubsub.SubscriptionConfig{
		Topic: request_topic,
		PushConfig: pubsub.PushConfig{
			Endpoint: os.Getenv("DATA_PROCESSING_REQUEST_PUSH_SUBSCRIPTION_URI"),
		},
	})
	handle(err)

	// make topic for data processing responses
	response_topic, err := client.CreateTopic(ctx, os.Getenv("DATA_PROCESSING_RESPONSE_TOPIC"))
	handle(err)
	defer response_topic.Stop()
}
