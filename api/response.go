package main

import (
	"github.com/go-chi/render"
	"net/http"
)

type ErrorResponse struct {
	Err        error  `json:"err"`
	StatusCode int    `json:"statusCode"`
	Message    string `json:"message"`
}

func (e ErrorResponse) Render(w http.ResponseWriter, r *http.Request) error {
	render.Status(r, e.StatusCode)
	return nil
}

func ErrBody(err error, statusCode int) render.Renderer {
	return &ErrorResponse{
		Err:        err,
		StatusCode: statusCode,
		Message:    err.Error(),
	}
}

var BadRequestException = &ErrorResponse{StatusCode: 400, Message: "Bad Request"}
var UnauthorizedException = &ErrorResponse{StatusCode: 401, Message: "Unauthorized"}
