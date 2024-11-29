FROM alpine:latest AS builder

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    CONTAINER_BUILD=1

WORKDIR /go/src/github.com/cloudflare/cloudflared/

RUN apk update && apk --no-cache --virtual build-dependendencies add build-base go git bash

RUN git clone https://github.com/cloudflare/cloudflared.git .

RUN .teamcity/install-cloudflare-go.sh

RUN sed -i '/else ifeq ($(LOCAL_ARCH),s390x)/s/^/else ifeq ($(LOCAL_ARCH),riscv64)\n	TARGET_ARCH ?= riscv64\nelse ifeq ($(LOCAL_ARCH),ppc64le)\n	TARGET_ARCH ?= ppc64le\n/' /go/src/github.com/cloudflare/cloudflared/Makefile

RUN PATH="/tmp/go/bin:$PATH" make cloudflared

FROM alpine:latest

COPY --from=builder /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/

ENTRYPOINT ["cloudflared", "--no-autoupdate"]
CMD ["version"]
