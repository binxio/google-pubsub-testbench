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
	project := os.Getenv("PUBSUB_PROJECT_ID")

	client, err := pubsub.NewClient(ctx, project); handle(err)

	request_topic, err := client.CreateTopic(ctx, "data-processing-request-topic"); handle(err)
	defer request_topic.Stop()

	response_topic, err := client.CreateTopic(ctx, "data-processing-response-topic"); handle(err)
	defer response_topic.Stop()

	_, err = client.CreateSubscription(ctx, "data-processing-request-subscription", pubsub.SubscriptionConfig{
		Topic: request_topic,
		PushConfig: pubsub.PushConfig{
			Endpoint: "http://data-processor:8081/",
		},
	})
	handle(err)
}
