VERSION ?=$(shell git describe --tags --dirty 2>/dev/null || git symbolic-ref -q --short HEAD)
COMMIT_HASH ?= $(shell git rev-parse --short HEAD 2>/dev/null)

# remove debug info from the binary & make it smaller
LDFLAGS += -s -w
# inject build info
LDFLAGS += -X main.Version=${VERSION} -X main.GitCommit=${COMMIT_HASH}

.PHONY: build
build:
	go build ${GOARGS} -tags "${GOTAGS}" -ldflags "${LDFLAGS}"

.PHONY: docker-build
docker-build:
	docker build -t inlets .
	docker tag inlets benono/inlets

.PHONY: publish
publish:
	docker push benono/inlets

