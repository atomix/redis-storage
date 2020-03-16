export CGO_ENABLED=0
export GO111MODULE=on

.PHONY: build


test: # @HELP run the unit tests and source code validation
test: build license_check linters
	go test github.com/atomix/redis-proxy/pkg/...

coverage: # @HELP generate unit test coverage data
coverage: build linters license_check

build: # @HELP ensure that the required dependencies are in place
	go build -v ./...
	bash -c "diff -u <(echo -n) <(git diff go.mod)"
	bash -c "diff -u <(echo -n) <(git diff go.sum)"

linters: # @HELP examines Go source code and reports coding problems
	golangci-lint run

license_check: # @HELP examine and ensure license headers exist
	@if [ ! -d "../build-tools" ]; then cd .. && git clone https://github.com/onosproject/build-tools.git; fi
	./../build-tools/licensing/boilerplate.py -v --rootdir=${CURDIR}

protos: # @HELP compile the protobuf files (using protoc-go Docker)
	docker run -it -v `pwd`:/go/src/github.com/atomix/redis-proxy \
		-w /go/src/github.com/atomix/redis-proxy \
		--entrypoint build/bin/compile-protos.sh \
		onosproject/protoc-go:stable



all: test


clean: # @HELP remove all the build artifacts
	rm -rf ./build/_output ./vendor

help:
	@grep -E '^.*: *# *@HELP' $(MAKEFILE_LIST) \
    | sort \
    | awk ' \
        BEGIN {FS = ": *# *@HELP"}; \
        {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}; \
    '
