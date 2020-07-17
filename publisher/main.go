package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"

	"cloud.google.com/go/pubsub"
)


var topic *pubsub.Topic
var ctx context.Context


func main() {


	var err error

	ctx = context.Background()
	project := os.Getenv("PUBSUB_PROJECT_ID")
	client, err := pubsub.NewClient(ctx, project)
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}

	topic, err = client.CreateTopic(ctx, "my-topic")
	if err != nil && !strings.Contains(err.Error(), "AlreadyExists") {
		log.Fatalf("Failed to create topic: %v", err)
	} else {
		topic = client.TopicInProject("my-topic", project)
		err = nil
	}

	defer topic.Stop()

	port := os.Getenv("8080")
	if port == "" {
		port = "8080"
	}
	http.HandleFunc("/", Forward)
	log.Printf("start to listen port port %s", port)
	err = http.ListenAndServe("0.0.0.0:" + port, nil)
	if err != nil {
		log.Fatal(err)
	}
}

func Forward(w http.ResponseWriter, r *http.Request) {
	var body interface{}

	err := json.NewDecoder(r.Body).Decode(&body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	js, err := json.Marshal(body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	result := topic.Publish(ctx, &pubsub.Message{Data: js})
	messageId, err := result.Get(ctx)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	fmt.Fprintf(w, "message sent, assigned message id %s\n", messageId)
}

