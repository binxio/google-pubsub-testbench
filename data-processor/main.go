package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

func handle(e error, w http.ResponseWriter, errorType string) {
	if e != nil {
    switch errorType {
	    case "400":
	      http.Error(w, e.Error(), http.StatusBadRequest)
			case "500":
				http.Error(w, e.Error(), http.StatusInternalServerError)
		}
	}
}


func Echo(w http.ResponseWriter, r *http.Request) {
	var body interface{}

	err := json.NewDecoder(r.Body).Decode(&body); handle(err, w, "400")
	js, err := json.Marshal(body); handle(err, w, "500")
	//
	w.Header().Set("Content-Type", "application/json")
	w.Write(js)

	log.Printf("app echoed %d bytes\n", len(js))
}


func main() {
	port := os.Getenv("PORT")

	http.HandleFunc("/", Echo)
	err := http.ListenAndServe("0.0.0.0:" + port, nil)
	if err != nil {
		log.Fatal(err)
	}
}
