package main

import (
	"cloud.google.com/go/pubsub"
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"os"
	"strings"
)

// declare data location in JSON structure that is pushed by pubsub.
// omitempty to generate error
type PubSubMessage struct {
	Message struct {
		Data string `json:"data,omitempty"`
	} `json:"message"`
}

func handle(e error, w http.ResponseWriter, httpResponseCode int) {
	if e != nil {
		http.Error(w, e.Error(), httpResponseCode)
		if httpResponseCode >= 500 && httpResponseCode < 600 {
			panic(e)
		}
	}
}

func transform(s string) string {
	// for demonstration, perform simple operation
	return strings.ToUpper(s)
}

func process(w http.ResponseWriter, r *http.Request) {
	switch method := r.Method; method {
	// accept only POST
	case http.MethodPost:
		// load context
		ctx := context.Background()
		projectID := os.Getenv("PROJECT_ID")
		data_processing_response_topic_id := os.Getenv("DATA_PROCESSING_RESPONSE_TOPIC")

		// decode JSON that is nested, pushed by pubsub and base64 to message
		var body PubSubMessage
		err := json.NewDecoder(r.Body).Decode(&body)
		handle(err, w, http.StatusBadRequest)
		message, err := base64.StdEncoding.DecodeString(body.Message.Data)
		handle(err, w, http.StatusBadRequest)

		// do some operation on the message
		responseMessage := transform(string(message))

		// connect to pubsub service
		client, err := pubsub.NewClient(ctx, projectID)
		handle(err, w, http.StatusInternalServerError)

		// publish the processed message
		res := client.Topic(data_processing_response_topic_id).Publish(ctx, &pubsub.Message{Data: []byte(responseMessage)})
		_, err = res.Get(ctx)
		handle(err, w, http.StatusInternalServerError)

		// acknowledge initial request message
		w.WriteHeader(http.StatusOK)

		// log
		log.Printf("capitalized [%s] to\n[%s] and\npublished on [%s].\n", message, responseMessage, data_processing_response_topic_id)

	// if not POST:
	default:
		handle(errors.New("wrong request type"), w, http.StatusBadRequest)
	}
}

func main() {
	// minimal handler. Portnumber is fixed to 8080 by GCP Cloud Run
	http.HandleFunc("/", process)
	log.Printf("data-processor started listening")
	err := http.ListenAndServe(":8080", nil) // portnumber is fixed by Cloud Run
	if err != nil {
		log.Fatal(err)
	}
}
