FROM --platform=$BUILDPLATFORM golang:latest AS builder

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    CONTAINER_BUILD=1

ARG TARGETPLATFORM

WORKDIR /go/src/cloudflared/

ADD https://github.com/cloudflare/cloudflared.git .

RUN .teamcity/install-cloudflare-go.sh

RUN case "$TARGETPLATFORM" in \
        "linux/386") GOOS=linux GOARCH=386 PATH="/tmp/go/bin:$PATH" make cloudflared ;; \
        "linux/s390x") GOOS=linux GOARCH=s390x PATH="/tmp/go/bin:$PATH" make cloudflared ;; \
        "linux/amd64") GOOS=linux GOARCH=amd64 PATH="/tmp/go/bin:$PATH" make cloudflared ;; \
        "linux/arm/v5") GOOS=linux GOARCH=arm GOARM=5 PATH="/tmp/go/bin:$PATH" make cloudflared ;; \
        "linux/arm/v6") GOOS=linux GOARCH=arm GOARM=6 PATH="/tmp/go/bin:$PATH" make cloudflared ;; \
        "linux/arm/v7") GOOS=linux GOARCH=arm GOARM=7 PATH="/tmp/go/bin:$PATH" make cloudflared ;; \
        "linux/arm64/v8") GOOS=linux GOARCH=arm64 GOARM=8 PATH="/tmp/go/bin:$PATH" make cloudflared ;; \
        "linux/ppc64le") GOOS=linux GOARCH=ppc64le PATH="/tmp/go/bin:$PATH" make cloudflared ;; \
        "linux/riscv64") GOOS=linux GOARCH=riscv64 PATH="/tmp/go/bin:$PATH" make cloudflared ;; \
        "linux/mips64le") GOOS=linux GOARCH=mips64le GOMIPS64LE=hardfloat PATH="/tmp/go/bin:$PATH" make cloudflared ;; \
    esac

FROM busybox:latest

COPY --from=builder /go/src/cloudflared/cloudflared /usr/local/bin/

ENTRYPOINT ["cloudflared", "--no-autoupdate"]

CMD ["version"]
