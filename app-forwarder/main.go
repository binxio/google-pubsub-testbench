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
			client, err := pubsub.NewClient(ctx, "speeltuin-teindevries"); handle(err, w, "500")

			topicName := os.Getenv("DATA_PROCESSING_REQUEST_TOPIC_ID")
			res := client.Topic(topicName).Publish(ctx, &pubsub.Message{Data: []byte(msg.Text)})
			_, err = res.Get(ctx); handle(err, w, "500")

			log.Printf("published: [%s] to [%s]\n", msg.Text, topicName)
		default:
			w.WriteHeader(http.StatusBadRequest)
	}
}

func main() {
	port := os.Getenv("PORT")
	address := os.Getenv("ADDRESS")

	http.HandleFunc("/", publish)
	log.Printf("start to listen port port %s\n", port)
	err := http.ListenAndServe(address + ":" + port, nil)
	if err != nil {
		log.Fatal(err)
	}
}
