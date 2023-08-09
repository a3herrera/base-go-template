FROM golang:1.19.9 as builder

COPY ./.ssh /root/.ssh
RUN chmod 600 /root/.ssh/*
RUN ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

RUN git config --global url."git@github.com:".insteadOf "https://github.com/"

RUN mkdir /build
WORKDIR /build

ADD ./ .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -gcflags=-trimpath=$PWD -o main .

FROM alpine:3.17.3

ENV GOROOT /usr/local/go
ADD https://github.com/golang/go/raw/master/lib/time/zoneinfo.zip /usr/local/go/lib/time/zoneinfo.zip

# RUN mkdir -p /app && adduser -S -D -H -h /app appuser && chown -R appuser /app
RUN mkdir -p /app/config
COPY --from=builder /build/main /build/notifications/area-codes.properties /app/
COPY --from=builder /build/i18n/locales/ /app/locales/
# COPY --from=builder /build/config.toml  /app/config/
# USER appuser
EXPOSE 9000
WORKDIR /app
CMD ["./main"]
