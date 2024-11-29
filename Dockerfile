ARG TARGET_GOOS
ARG TARGET_GOARCH

FROM alpine:latest AS builder

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    TARGET_GOOS=${TARGET_GOOS} \
    TARGET_GOARCH=${TARGET_GOARCH} \
    CONTAINER_BUILD=1

RUN apk update && apk --no-cache --virtual build-dependendencies add build-base go git bash

RUN cd /tmp && git clone -q https://github.com/cloudflare/go \
	&& cd go/src \
	&& git checkout -q f4334cdc0c3f22a3bfdd7e66f387e3ffc65a5c38 \
	&& ./make.bash

RUN mkdir -p /go/src/github.com/cloudflare \
	&& cd /go/src/github.com/cloudflare \
	&& git clone https://github.com/cloudflare/cloudflared.git

RUN sed -i '/else ifeq ($(LOCAL_ARCH),s390x)/s/^/else ifeq ($(LOCAL_ARCH),riscv64)\n	TARGET_ARCH ?= riscv64\nelse ifeq ($(LOCAL_ARCH),ppc64le)\n	TARGET_ARCH ?= ppc64le\n/' /go/src/github.com/cloudflare/cloudflared/Makefile

RUN PATH="/tmp/go/bin:$PATH" make cloudflared -j$(nproc)

FROM alpine:latest

COPY --from=builder /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/

ENTRYPOINT ["cloudflared", "--no-autoupdate"]
CMD ["version"]
