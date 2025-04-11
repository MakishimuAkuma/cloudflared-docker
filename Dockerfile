FROM golang:alpine AS builder

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    CONTAINER_BUILD=1

WORKDIR /go/src/cloudflared/

ADD https://github.com/cloudflare/cloudflared.git#2025.4.0 .

RUN apk update && apk add git bash

RUN .teamcity/install-cloudflare-go.sh

RUN sed -i '/else ifeq ($(LOCAL_ARCH),s390x)/s/^/else ifeq ($(LOCAL_ARCH),riscv64)\n	TARGET_ARCH ?= riscv64\nelse ifeq ($(LOCAL_ARCH),ppc64le)\n	TARGET_ARCH ?= ppc64le\n/' /go/src/cloudflared/Makefile

RUN PATH="/tmp/go/bin:$PATH" make cloudflared

FROM busybox:stable-glibc

COPY --from=builder /go/src/cloudflared/cloudflared /usr/local/bin/

ENTRYPOINT ["cloudflared", "--no-autoupdate"]

CMD ["version"]
