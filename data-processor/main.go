package main

import (
	"cloud.google.com/go/pubsub"
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strings"
	"encoding/base64"
)

type PubSubMessage struct {
        Message struct {
                Data string `json:"data,omitempty"`
                MessageID   string `json:"id"`
        } `json:"message"`
}

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

func veryComplicatedOperation(s string) string {
	return strings.ToUpper(s)
}

func process(w http.ResponseWriter, r *http.Request) {
	var body PubSubMessage; err := json.NewDecoder(r.Body).Decode(&body); handle(err, w, "400")

	message, err := base64.StdEncoding.DecodeString(body.Message.Data); handle(err, w, "400")
	responseMessage := veryComplicatedOperation(string(message))

	projectID := os.Getenv("PROJECT_ID")
	ctx := context.Background() // <- do this here, or cleaner at beginning?
	client, err := pubsub.NewClient(ctx, projectID); handle(err, w, "500")

	data_processing_response_topic_id := os.Getenv("DATA_PROCESSING_RESPONSE_TOPIC_ID") + "-topic"
	res := client.Topic(data_processing_response_topic_id).Publish(ctx, &pubsub.Message{Data: []byte(responseMessage)})
	_, err = res.Get(ctx); handle(err, w, "500")
	w.WriteHeader(http.StatusOK)

	log.Printf("capitalized [%s] to [%s] \n", body.Message.Data, responseMessage)
}

func main() {
	http.HandleFunc("/", process)
	log.Printf("data-processor started listening")
	err := http.ListenAndServe(":" + os.Getenv("PORT"), nil)
	if err != nil {
		log.Fatal(err)
	}
}
