package main

import (
	"bytes"
	"cloud.google.com/go/pubsub"
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strings"
)

func Forwarder(ctx context.Context, m *pubsub.Message) {
	log.Printf("sending %d bytes\n", len(m.Data))
	r, err := http.Post("http://app:8080", "application/json", bytes.NewBuffer(m.Data))

	if err == nil && r.StatusCode == 200 {
		m.Ack()
	} else {
		if err != nil {
			log.Printf("failed to delivery message, %s\n", err)
		} else {
			log.Printf("application returned %d\n", r.StatusCode)
		}
		m.Nack()
	}
}

func main() {
	var err error
	var topic *pubsub.Topic
	var subscription *pubsub.Subscription

	ctx := context.Background()
	project := os.Getenv("PUBSUB_PROJECT_ID")
	client, err := pubsub.NewClient(ctx, project)
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}

	topic, err = client.CreateTopic(ctx, "my-topic");
	if err != nil && !strings.Contains(err.Error(), "AlreadyExists") {
		log.Fatalf("Failed to create topic: %v", err)
	} else {
		topic = client.TopicInProject("my-topic", project)
		err = nil
	}
	defer topic.Stop();

	subscription, err = client.CreateSubscription(context.Background(), "my-topic-app-forwarder",
		pubsub.SubscriptionConfig{Topic: topic})
	if err != nil && !strings.Contains(err.Error(), "AlreadyExists") {
		log.Fatalf("failed to create subscription: %s", err)
	} else {
		subscription = client.SubscriptionInProject("my-topic-app-forwarder", project)
		err = nil
	}
	err = subscription.Receive(ctx, Forwarder)
	if err != nil {
		log.Fatalf("receive failed, %s", err)
	}



	body, err := ioutil.ReadAll(os.Stdin); if err == nil {
		result := topic.Publish(ctx, &pubsub.Message{Data: body})
		server, err := result.Get(ctx); if err == nil {
			fmt.Printf("message sent to %s", server)
		}
	}
	if err != nil {
		log.Fatal("failed to publish message, %s", err)
	}
}

