package main

import (
	"cloud.google.com/go/pubsub"
	"encoding/json"
	"context"
	"log"
	"net/http"
	"os"
	// "github.com/davecgh/go-spew/spew"
)

type MinimalPubSubMessage struct {
	Text string
}

//TODO not DRY: repetition across scripts, don't yet know how to modularize in Go.
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
	ctx := context.Background()
	switch method := r.Method; method{
		case http.MethodPost:
			var msg MinimalPubSubMessage; err := json.NewDecoder(r.Body).Decode(&msg); handle(err, w, "400")

			topicName := os.Getenv("DATA_PROCESSING_TOPIC_ID")
			log.Printf("topic: %s\n", topicName)
			client, err := pubsub.NewClient(ctx, "speeltuin-teindevries"); handle(err, w, "500")
			log.Printf("trying to publish: %s\n", msg.Text)
			res := client.Topic(topicName).Publish(ctx, &pubsub.Message{Data: []byte(msg.Text)})
			serverID, err := res.Get(ctx); handle(err, w, "500")
			log.Printf("result: %s\n", serverID)
		default:
			w.WriteHeader(http.StatusBadRequest)
	}
}

func main() {
	port := os.Getenv("PORT")

	http.HandleFunc("/", publish)
	log.Printf("start to listen port port %s\n", port)
	err := http.ListenAndServe(":" + port, nil)
	if err != nil {
		log.Fatal(err)
	}
}
