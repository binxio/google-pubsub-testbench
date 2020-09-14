package main

import (
	"cloud.google.com/go/pubsub"
	"context"
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"os"
)

// TODO
// put one time setup in global variables (e.g. clients)

type MinimalPubSubMessage struct {
	Text string
}

func handle(e error, w http.ResponseWriter, httpResponseCode int) {
	if e != nil {
		http.Error(w, e.Error(), httpResponseCode)
		if httpResponseCode >= 500 && httpResponseCode < 600 {
			panic(e)
		}
	}
}

func publish(w http.ResponseWriter, r *http.Request) {
	switch method := r.Method; method {
	// accept only POST
	case http.MethodPost:
		// load context
		ctx := context.Background()
		projectID := os.Getenv("PROJECT_ID")
		data_processing_request_topic_id := os.Getenv("DATA_PROCESSING_REQUEST_TOPIC")

		// decode simple JSON to a message
		var msg MinimalPubSubMessage
		err := json.NewDecoder(r.Body).Decode(&msg)
		handle(err, w, http.StatusBadRequest)

		// connect to pubsub service
		client, err := pubsub.NewClient(ctx, projectID)
		handle(err, w, http.StatusInternalServerError)

		// publish the message
		res := client.Topic(data_processing_request_topic_id).Publish(ctx, &pubsub.Message{Data: []byte(msg.Text)})
		_, err = res.Get(ctx)
		handle(err, w, http.StatusInternalServerError)

		// respond positively
		w.WriteHeader(http.StatusOK)

		// log
		log.Printf("published: [%s] to [%s]\n", msg.Text, data_processing_request_topic_id)

	// if not POST:
	default:
		handle(errors.New("wrong request type"), w, http.StatusBadRequest)
	}
}

func main() {
	// minimal handler. Portnumber is fixed to 8080 by GCP Cloud Run
	http.HandleFunc("/", publish)
	log.Printf("app-forwarder started listening")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal(err)
	}
}
