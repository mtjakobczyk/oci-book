package main

import (
	"os"
	"log"
	"encoding/json"
	"net/http"
	"github.com/gorilla/mux"
	"github.com/google/uuid"
)

type Result struct {
		UUID 			string `json:"uuid,omitempty"`
		Generator 	string `json:"generator"`
}

const DefaultVistulaPort = "8085"
var VistulaGeneratorName string

func main() {
	log.Println("starting Vistula API")
	r := mux.NewRouter()
	r.HandleFunc("/identifiers", UUIDHandler).Methods("GET")
	VistulaGeneratorName = getVistulaNodeName()
	vistulaPort := getServerPort()
	log.Println("Vistula node name " + VistulaGeneratorName)
	log.Println("Vistula will listen on port " + vistulaPort)
	log.Fatal(http.ListenAndServe(":" + vistulaPort, r))
	log.Println("stopping Vistula API")
}

func UUIDHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	generatedId, err := uuid.NewRandom()
	if err != nil {
		log.Fatal(err)
	}
	result := Result{UUID: generatedId.String(), Generator: VistulaGeneratorName}
	json.NewEncoder(w).Encode(result)
}

func getServerPort() (string) {
	port := os.Getenv("VISTULA_PORT")
	if port != "" {
		return port
	}
	return DefaultVistulaPort
}

func getVistulaNodeName() (string) {
	nodeName := os.Getenv("VISTULA_GENERATOR_NAME")
	if nodeName != "" {
		return nodeName
	}
	hostname, err := os.Hostname()
	if err != nil {
		log.Fatal(err)
	}
	return hostname
}
