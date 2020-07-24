package main

import {
  "fmt"
  "log"
  "net/http"
}

func handler(w http.ResponseWriter, r http.Request) {
  body := `<h1>Hoi Tein !<h1>`
  fmt.Fprint(w, body)
}

func main() {
  log.Print("Teinie!")

  http.HandleFunc("/", handler)

  port := "8080"

  log.Fatal(
    http.ListenAndServe(
      fmt.Sprintf(":%s", port),
      nil
      )
    )
