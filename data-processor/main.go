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

	// "github.com/davecgh/go-spew/spew"
)

type PubSubMessage struct {
        Message struct {
                Data string `json:"data,omitempty"`
                MessageID   string `json:"id"`
        } `json:"message"`
        // Subscription string `json:"subscription"`
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

func echo(w http.ResponseWriter, r *http.Request) {
	// var body interface{}
	var body PubSubMessage

	err := json.NewDecoder(r.Body).Decode(&body); handle(err, w, "400")
	message, err := base64.StdEncoding.DecodeString(body.Message.Data); handle(err, w, "400")
	responseMessage := veryComplicatedOperation(string(message))
	// js, err := json.Marshal(body); handle(err, w, "500")
	topicName := os.Getenv("DATA_PROCESSING_RESPONSE_TOPIC_ID")
	ctx := context.Background()
	client, err := pubsub.NewClient(ctx, "speeltuin-teindevries"); handle(err, w, "500")
	res := client.Topic(topicName).Publish(ctx, &pubsub.Message{Data: []byte(responseMessage)})
	_, err = res.Get(ctx); handle(err, w, "500")
	w.WriteHeader(http.StatusOK)


	log.Printf("capitalized [%s] to [%s] \n", body.Message.Data, responseMessage)
}


func main() {
	port := os.Getenv("PORT")

	http.HandleFunc("/", echo)
	log.Printf("start to listen port port %s\n", port)
	err := http.ListenAndServe(":" + port, nil)
	if err != nil {
		log.Fatal(err)
	}
}
