package main

import (
	"context"
	firebase "firebase.google.com/go/v4"
	"fmt"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/render"
	"github.com/joho/godotenv"
	"github.com/sashabaranov/go-openai"
	"log"
	"net/http"
	"os"
)

func init() {
	if os.Getenv("ENV") != "prod" {
		err := godotenv.Load()
		if err != nil {
			panic(err)
		}
	}
}

func main() {
	client = openai.NewClient(os.Getenv("OPENAI_KEY"))
	port := os.Getenv("PORT")

	app, err := firebase.NewApp(context.Background(), nil)

	if err != nil {
		log.Fatalf("error initializing app: %v\n", err)
	}

	if port == "" {
		port = "8080"
	}

	auth, err := app.Auth(context.Background())

	if err != nil {
		log.Fatalf("error initializing auth client %v\n", err)
	}

	r := chi.NewRouter()

	r.Use(middleware.RequestID)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(render.SetContentType(render.ContentTypeJSON))
	r.Use(AuthMiddleware(auth))

	r.Route("/receipts", ReceiptRoute)

	err = http.ListenAndServe(":"+port, r)
	if err != nil {
		log.Fatalf("[Server Error]: %s", err.Error())
	} else {
		fmt.Println("[Server]: Connection Established")
	}
}
