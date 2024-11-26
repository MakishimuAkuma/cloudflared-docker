FROM golang:latest AS builder
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    CONTAINER_BUILD=1


WORKDIR /go/src/github.com/cloudflare/cloudflared/

# copy our sources into the builder image
RUN git clone https://github.com/cloudflare/cloudflared.git .

RUN .teamcity/install-cloudflare-go.sh

# compile cloudflared
RUN PATH="/tmp/go/bin:$PATH" make cloudflared

# use a distroless base image with glibc
FROM alpine:latest

LABEL org.opencontainers.image.source="https://github.com/cloudflare/cloudflared"

# copy our compiled binary
COPY --from=builder /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/

# command / entrypoint of container
ENTRYPOINT ["cloudflared", "--no-autoupdate"]
CMD ["version"]
