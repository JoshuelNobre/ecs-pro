FROM fidelissauro/apko-go:latest-amd64 AS builder

WORKDIR /root/src/app

# dependências em camada própria: só refaz o download quando go.mod ou go.sum mudam
COPY go.mod go.sum ./

RUN go mod download

COPY . ./

RUN CGO_ENABLED=0 GOOS=linux go build -o main .

FROM fidelissauro/apko-run:latest-amd64

COPY --from=builder /root/src/app/main ./

EXPOSE 8080

ENTRYPOINT ["./main"]
