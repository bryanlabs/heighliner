FROM golang:alpine AS build-env
ARG VERSION
ARG NAME
ARG GITHUB_ORGANIZATION
ARG GITHUB_REPO
ARG BINARY
ARG MAKE_TARGET
ARG BUILD_ENV

ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev

RUN apk add --no-cache $PACKAGES

WORKDIR /go/src/github.com/${GITHUB_ORGANIZATION}

RUN git clone https://github.com/${GITHUB_ORGANIZATION}/${GITHUB_REPO}.git

WORKDIR /go/src/github.com/${GITHUB_ORGANIZATION}/${GITHUB_REPO}

ADD https://github.com/CosmWasm/wasmvm/releases/download/v1.0.0-beta5/libwasmvm_muslc.a /lib/libwasmvm_muslc.a
RUN sha256sum /lib/libwasmvm_muslc.a | grep d16a2cab22c75dbe8af32265b9346c6266070bdcf9ed5aa9b7b39a7e32e25fe0

RUN git checkout ${VERSION}

RUN export ${BUILD_ENV} && make ${MAKE_TARGET}

RUN cp ${BINARY} /root/cosmos

RUN git clone https://github.com/tendermint/tendermint && \
  cd tendermint && \
  git checkout remotes/origin/callum/app-version && \
  go install ./...

FROM alpine:edge

ARG BINARY
ENV BINARY ${BINARY}

RUN apk add --no-cache ca-certificates jq curl git
WORKDIR /root

# Install tendermint
COPY --from=build-env /go/bin/tendermint /usr/bin/

# Install chain binary
COPY --from=build-env /root/cosmos .
RUN mv /root/cosmos /usr/bin/$(basename $BINARY)

EXPOSE 26657

CMD env $(basename $BINARY) start
