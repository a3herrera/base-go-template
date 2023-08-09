package main

import (
	"github.com/gorilla/mux"
	"net/http"
	"time"
)

func main() {
	router := mux.NewRouter()

	// Health check
	router.HandleFunc("/", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	})

	server := &http.Server{
		Addr:              ":9000",
		Handler:           router,
		ReadHeaderTimeout: 5 * time.Second,
	}

	if startServerError := server.ListenAndServe(); startServerError != nil {
		panic(startServerError)
	}
}
