package main

import (
	"cloud.google.com/go/pubsub"
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"errors"
)

type MinimalPubSubMessage struct {
	Text string
}

func handle(e error, w http.ResponseWriter, errorType string) {
	// handle multiple errors
	if e != nil {
    switch errorType {
	    case "400":
	      http.Error(w, e.Error(), http.StatusBadRequest)
			case "500":
				http.Error(w, e.Error(), http.StatusInternalServerError)
		}
		// always panic in case of error, during dev
		panic(e)
	}
}

func publish(w http.ResponseWriter, r *http.Request) {
	switch method := r.Method; method{
		// accept only POST
		case http.MethodPost:
			// load context
			ctx := context.Background()
			projectID := os.Getenv("PROJECT_ID")
			data_processing_request_topic_id := os.Getenv("DATA_PROCESSING_REQUEST_TOPIC_ID") + "-topic"

			// decode simple JSON to a message
			var msg MinimalPubSubMessage; err := json.NewDecoder(r.Body).Decode(&msg); handle(err, w, "400")

			// connect to pubsub service
			client, err := pubsub.NewClient(ctx, projectID); handle(err, w, "500")

			// publish the message
			res := client.Topic(data_processing_request_topic_id).Publish(ctx, &pubsub.Message{Data: []byte(msg.Text)})
			_, err = res.Get(ctx); handle(err, w, "500")

			// respond positively
			w.WriteHeader(http.StatusOK)

			// log
			log.Printf("published: [%s] to [%s]\n", msg.Text, data_processing_request_topic_id)

		// if not POST:
		default:
			handle(errors.New("wrong request type"), w, "400")
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
