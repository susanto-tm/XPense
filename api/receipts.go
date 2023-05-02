package main

import (
	"errors"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/render"
	"log"
	"net/http"
)

type ReceiptItem struct {
	Name     string  `json:"name"`
	Quantity float32 `json:"quantity"`
	Price    float32 `json:"price"`
}

type Receipt struct {
	Name     string        `json:"name"`
	Category string        `json:"category"`
	Total    float64       `json:"total"`
	Items    []ReceiptItem `json:"items"`
}

type ParseReceiptBody struct {
	Context string `json:"context"`
}

func (p *ParseReceiptBody) Bind(r *http.Request) error {
	if p.Context == "" {
		return errors.New("missing document context")
	}
	return nil
}

type ParseReceiptResponse struct {
	Document Receipt `json:"document"`
}

func (p ParseReceiptResponse) Render(w http.ResponseWriter, r *http.Request) error {
	return nil
}

func ReceiptRoute(r chi.Router) {
	r.Post("/parse", ParseReceipt)
}

func ParseReceipt(w http.ResponseWriter, r *http.Request) {
	data := &ParseReceiptBody{}
	if err := render.Bind(r, data); err != nil {
		err := render.Render(w, r, BadRequestException)
		if err != nil {
			log.Fatal(err.Error())
		}
		return
	}
	document := DocumentContext{context: data.Context}
	receipt, err := document.GptReceiptCompletion()

	if err != nil {
		_ = render.Render(w, r, ErrBody(err, 500))
		return
	}

	_ = render.Render(w, r, &ParseReceiptResponse{Document: receipt})
}
