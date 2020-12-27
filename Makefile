ARCH               = $(or $(shell printenv ARCH),$(shell echo linux/amd64,linux/arm64,linux/arm/v7))
CREATED            = $(or $(shell printenv CREATED),$(shell date --rfc-3339=seconds))
DOCKER_INTERACTIVE = $(if $(shell printenv GITHUB_ACTIONS),-t,-it)
IMAGE              = $(or $(shell printenv IMAGE),cewood/offlineimap)
GIT_REVISION       = $(or $(shell printenv GIT_REVISION), $(shell git describe --match= --always --abbrev=7 --dirty))


.PHONY: dists
dists: alpine debian ubuntu

.PHONY: ubuntu
ubuntu:
	$(MAKE) build-load DIST=ubuntu

.PHONY: debian
debian:
	$(MAKE) build-load DIST=debian

.PHONY: alpine
alpine:
	$(MAKE) build-load DIST=alpine

.PHONY: build
build:
	DOCKER_CLI_EXPERIMENTAL=enabled \
	docker \
	  buildx build \
	  --platform ${ARCH} \
	  --build-arg REVISION="${GIT_REVISION}" \
	  --build-arg CREATED="${CREATED}" \
	  --tag cewood/offlineimap:${DIST}_${GIT_REVISION} \
	  -f Dockerfile-${DIST} \
	  .

.PHONY: load
load:
	DOCKER_CLI_EXPERIMENTAL=enabled \
	docker \
	  buildx build \
	  --build-arg REVISION="${GIT_REVISION}" \
	  --build-arg CREATED="${CREATED}" \
	  --tag cewood/offlineimap:${DIST}_${GIT_REVISION} \
	  -f Dockerfile-${DIST} \
	  --load \
	  .

.PHONY: build-load
build-load:
	$(MAKE) build DIST="${DIST}" CREATED="${CREATED}"
	$(MAKE) load DIST="${DIST}" CREATED="${CREATED}"

.PHONY: inspect
inspect:
	docker inspect cewood/offlineimap:${DIST}_${GIT_REVISION}

.PHONY: binfmt-setup
binfmt-setup:
	docker \
	  run \
	  --rm \
	  --privileged \
	  docker/binfmt:66f9012c56a8316f9244ffd7622d7c21c1f6f28d

.PHONY: buildx-setup
buildx-setup:
	DOCKER_CLI_EXPERIMENTAL=enabled \
	docker \
	  buildx \
	  create \
	  --use \
	  --name multiarch
