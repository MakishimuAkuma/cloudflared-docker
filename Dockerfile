FROM alpine:latest AS builder

RUN apk update && apk --no-cache --virtual build-dependendencies add build-base gcc g++ go git bash

RUN cd /tmp && git clone -q https://github.com/cloudflare/go
RUN cd /tmp/go/src && ./make.bash

RUN mkdir /go/src/github.com/cloudflare
RUN cd /go/src/github.com/cloudflare
RUN git clone https://github.com/cloudflare/cloudflared.git

RUN sed -i '/else ifeq ($(LOCAL_ARCH),s390x)/s/^/else ifeq ($(LOCAL_ARCH),riscv64)\n	TARGET_ARCH ?= riscv64\nelse ifeq ($(LOCAL_ARCH),ppc64le)\n	TARGET_ARCH ?= ppc64le\n/' Makefile

RUN PATH="/tmp/go/bin:$PATH" make cloudflared -j$(nproc)

FROM alpine:latest

COPY --from=builder /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/

ENTRYPOINT ["cloudflared", "--no-autoupdate"]
CMD ["version"]
