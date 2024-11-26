FROM alpine:latest AS builder

WORKDIR /go/src/github.com/cloudflare/cloudflared/

RUN apk update && apk --no-cache --virtual build-dependendencies add build-base gcc g++ go git bash

# copy our sources into the builder image
RUN git clone https://github.com/cloudflare/cloudflared.git .

RUN sed -i '/else ifeq ($(LOCAL_ARCH),s390x)/s/^/else ifeq ($(LOCAL_ARCH),riscv64)\n	TARGET_ARCH ?= riscv64\nelse ifeq ($(LOCAL_ARCH),ppc64le)\n	TARGET_ARCH ?= ppc64le\n/' Makefile

# compile cloudflared
RUN make cloudflared -j$(nproc)

# use a distroless base image with glibc
FROM alpine:latest

LABEL org.opencontainers.image.source="https://github.com/cloudflare/cloudflared"

# copy our compiled binary
COPY --from=builder /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/

# command / entrypoint of container
ENTRYPOINT ["cloudflared", "--no-autoupdate"]
CMD ["version"]
