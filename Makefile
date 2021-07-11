Version := $(shell git describe --tags --dirty)
GitCommit := $(shell git rev-parse HEAD)
LDFLAGS := "-s -w -X main.Version=$(Version) -X main.GitCommit=$(GitCommit)"
LocalUser := alexellis

# docker manifest command will work with Docker CLI 18.03 or newer
# but for now it's still experimental feature so we need to enable that
export DOCKER_CLI_EXPERIMENTAL=enabled

.PHONY: all
all: docker

.PHONY: dist
dist:
	CGO_ENABLED=0 GOOS=linux go build -ldflags $(LDFLAGS) -a -installsuffix cgo -o bin/inlets
	CGO_ENABLED=0 GOOS=darwin go build -ldflags $(LDFLAGS) -a -installsuffix cgo -o bin/inlets-darwin

.PHONY: docker-local
docker-local:
	docker build \
		-t ghcr.io/$(LocalUser)/inlets:$(Version) .

.PHONY: docker
docker:
	@docker buildx create --use --name=multiarch --node multiarch && \
	docker buildx build \
		--progress=plain \
		--build-arg VERSION=$(Version) --build-arg GIT_COMMIT=$(GitCommit) \
		--platform linux/amd64,linux/arm/v6,linux/arm64 \
		--output "type=image,push=false" \
		--tag ghcr.io/inlets/inlets:$(Version) .

.PHONY: docker-login
docker-login:
	echo -n "${GHCR_PASSWORD}" | docker login -u "${GHCR_USERNAME}" --password-stdin ghcr.io

.PHONY: push
push:
	@docker buildx create --use --name=multiarch --node multiarch && \
	docker buildx build \
		--progress=plain \
		--build-arg VERSION=$(Version) --build-arg GIT_COMMIT=$(GitCommit) \
		--platform linux/amd64 \
		--output "type=image,push=true" \
		--tag ghcr.io/inlets/inlets:$(Version) .
