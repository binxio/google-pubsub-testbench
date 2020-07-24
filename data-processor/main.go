package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

func Echo(w http.ResponseWriter, r *http.Request) {
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
	log.Printf("app echoed %d bytes\n", len(js))

	w.Header().Set("Content-Type", "application/json")
	w.Write(js)
}


func main() {
	port := os.Getenv("8080")
	if port == "" {
		port = "8080"
	}
	http.HandleFunc("/", Echo)
	err := http.ListenAndServe("0.0.0.0:" + port, nil)
	if err != nil {
		log.Fatal(err)
	}
}
