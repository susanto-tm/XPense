FROM golang:1.20.3-alpine3.17 AS build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY *.go .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o api

FROM alpine

COPY --from=build /app/api .

CMD ["/api"]