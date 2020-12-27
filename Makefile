ARCH               = $(or $(shell printenv ARCH),$(shell echo linux/amd64,linux/arm64,linux/arm/v7))
BUILD_FLAGS        = $(or $(shell printenv BUILD_FLAGS),--pull)
CREATED            = $(or $(shell printenv CREATED),$(shell date --rfc-3339=seconds))
DISTS              = $(or $(shell printenv DISTS),alpine debian ubuntu)
DOCKER_INTERACTIVE = $(if $(shell printenv GITHUB_ACTIONS),-t,-it)
IMAGE              = $(or $(shell printenv IMAGE),cewood/offlineimap)
GIT_REVISION       = $(or $(shell printenv GIT_REVISION), $(shell git describe --match= --always --abbrev=7 --dirty))


.PHONY: dists
dists: $(patsubst %,build-%,${DISTS})

.PHONY: alpine
alpine: build-alpine

.PHONY: debian
debian: build-debian

.PHONY: ubuntu
ubuntu: build-ubuntu

.PHONY: build-%
build-%:
	$(MAKE) build DIST=$*

.PHONY: build
build:
	DOCKER_CLI_EXPERIMENTAL=enabled \
	docker \
	  buildx build \
	  ${BUILD_FLAGS} \
	  --build-arg CREATED="${CREATED}" \
	  --build-arg REVISION="${GIT_REVISION}" \
	  --platform ${ARCH} \
	  --tag cewood/offlineimap:${DIST}_${GIT_REVISION} \
	  -f Dockerfile-${DIST} \
	  .

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

.PHONY: ci
ci:
	$(MAKE) dists BUILD_FLAGS=$(if $(findstring tags,${GITHUB_REF}),--push,--pull)
