BRANCH=`git rev-parse --abbrev-ref HEAD`
COMMIT=`git rev-parse --short HEAD`
GOLDFLAGS="-X main.branch $(BRANCH) -X main.commit $(COMMIT)"

default: build

race:
	@TEST_FREELIST_TYPE=hashmap go test -v -race -test.run="TestSimulate_(100op|1000op)"
	@echo "array freelist test"
	@TEST_FREELIST_TYPE=array go test -v -race -test.run="TestSimulate_(100op|1000op)"

fmt:
	!(gofmt -l -s -d $(shell find . -name \*.go) | grep '[a-z]')

# go get honnef.co/go/tools/simple
gosimple:
	gosimple ./...

# go get honnef.co/go/tools/unused
unused:
	unused ./...

# go get github.com/kisielk/errcheck
errcheck:
	@errcheck -ignorepkg=bytes -ignore=os:Remove github.com/webfont-io/bbolt

test:
	TEST_FREELIST_TYPE=hashmap go test -timeout 20m -v -coverprofile cover.out -covermode atomic
	# Note: gets "program not an importable package" in out of path builds
	TEST_FREELIST_TYPE=hashmap go test -v ./cmd/bbolt

	@echo "array freelist test"

	@TEST_FREELIST_TYPE=array go test -timeout 20m -v -coverprofile cover.out -covermode atomic
	# Note: gets "program not an importable package" in out of path builds
	@TEST_FREELIST_TYPE=array go test -v ./cmd/bbolt

init:
	@git config --local user.name hkloudou
	@git config --local user.email hkloudou@gmail.com
	@git config --local user.signingkey 575A0CADC23D0A96
	@git config --local commit.gpgsign true
	@git config --local autotag.sign true
git:
	- git add . && git commit -S -m 'auto commit' && git push origin master -f --tags
tag:
	@ make mod
	- git add . && git commit -S -m 'auto tag'
	- git autotag && git push origin master -f --tags
	@echo "current version:`git describe`"
mod:
	go build ./...
.PHONY: race fmt errcheck test gosimple unused
