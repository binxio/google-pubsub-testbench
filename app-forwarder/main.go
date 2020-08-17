package main

import (
	"cloud.google.com/go/pubsub"
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
)

type MinimalPubSubMessage struct {
	Text string
}

//TODO not DRY: repetition across scripts, don't yet know if and how to modularize in Go.
func handle(e error, w http.ResponseWriter, errorType string) {
	if e != nil {
    switch errorType {
	    case "400":
	      http.Error(w, e.Error(), http.StatusBadRequest)
			case "500":
				http.Error(w, e.Error(), http.StatusInternalServerError)
		}
		panic(e)
	}
}

func publish(w http.ResponseWriter, r *http.Request) {
	switch method := r.Method; method{
		case http.MethodPost:
			var msg MinimalPubSubMessage; err := json.NewDecoder(r.Body).Decode(&msg); handle(err, w, "400")

			ctx := context.Background()
			projectID := os.Getenv("PROJECT_ID")
			client, err := pubsub.NewClient(ctx, projectID); handle(err, w, "500")

			data_processing_request_topic_id := os.Getenv("DATA_PROCESSING_REQUEST_TOPIC_ID") + "-topic"
			res := client.Topic(data_processing_request_topic_id).Publish(ctx, &pubsub.Message{Data: []byte(msg.Text)})
			_, err = res.Get(ctx); handle(err, w, "500")

			log.Printf("published: [%s] to [%s]\n", msg.Text, data_processing_request_topic_id)
		default:
			w.WriteHeader(http.StatusBadRequest)
	}
}

func main() {
	http.HandleFunc("/", publish)
	log.Printf("start to listen port port %s\n", port)
	err := http.ListenAndServe(":" + os.Getenv("PORT"), nil)
	if err != nil {
		log.Fatal(err)
	}
}
