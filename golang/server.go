package main

import (
	"fmt"
	"net/http"
)

func hello_response(w http.ResponseWriter, request *http.Request) {
	fmt.Fprint(w, "Hello World\n")
}

func headers(w http.ResponseWriter, request *http.Request) {
	for name, headers := range request.Header {
		for _, h := range headers {
			fmt.Fprintf(w, "%v: %v\n", name, h)
		}
	}
}

func main() {
	http.HandleFunc("/hello", hello_response)
	http.HandleFunc("/headers", headers)

	http.ListenAndServe(":8080", nil)
}
