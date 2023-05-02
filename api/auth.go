package main

import (
	"context"
	"firebase.google.com/go/v4/auth"
	"github.com/go-chi/render"
	"net/http"
	"strings"
)

func AuthMiddleware(auth *auth.Client) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			authorization := r.Header.Get("Authorization")

			if authorization == "" {
				_ = render.Render(w, r, UnauthorizedException)
				return
			}

			tokenSplit := strings.Split(authorization, "Bearer ")

			if len(tokenSplit) == 0 {
				_ = render.Render(w, r, UnauthorizedException)
				return
			}

			token := tokenSplit[1]

			_, err := auth.VerifyIDToken(context.Background(), token)

			if err != nil {
				_ = render.Render(w, r, UnauthorizedException)
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
