.SILENT :
.PHONY : volume build clean run shell test

USERNAME:=ncarlier
APPNAME:=webhookd
IMAGE:=$(USERNAME)/$(APPNAME)

TAG:=`git describe --abbrev=0 --tags`
LDFLAGS:=-X main.buildVersion $(TAG)
ROOTPKG:=github.com/$(USERNAME)
PKGDIR:=$(GOPATH)/src/$(ROOTPKG)

define docker_run_flags
--rm \
-v /var/run/docker.sock:/var/run/docker.sock \
--env-file $(PWD)/etc/env.conf \
-P \
-i -t
endef

ifdef DEVMODE
	docker_run_flags += --volumes-from $(APPNAME)_volumes
endif

all: build

volume:
	echo "Building $(APPNAME) volumes..."
	sudo docker run -v $(PWD):/opt/$(APPNAME) -v ~/var/$(APPNAME):/var/opt/$(APPNAME) --name $(APPNAME)_volumes busybox true

build:
	echo "Building $(IMAGE) docker image..."
	sudo docker build --rm -t $(IMAGE) .

clean:
	echo "Removing $(IMAGE) docker image..."
	sudo docker rmi $(IMAGE)

run:
	echo "Running $(IMAGE) docker image..."
	sudo docker run $(docker_run_flags) --name $(APPNAME) $(IMAGE)

shell:
	echo "Running $(IMAGE) docker image with shell access..."
	sudo docker run $(docker_run_flags) --entrypoint="/bin/bash" $(IMAGE) -c /bin/bash

test:
	echo "Running tests..."
	test.sh

dist-prepare:
	rm -rf $(PKGDIR)
	mkdir -p $(PKGDIR)
	ln -s $(PWD)/src $(PKGDIR)/$(APPNAME)
	rm -rf dist

dist: dist-prepare
#	godep restore
	mkdir -p dist/linux/amd64 && GOOS=linux GOARCH=amd64 go build -o dist/linux/amd64/$(APPNAME) ./src
	tar -cvzf dist/$(APPNAME)-linux-amd64-$(TAG).tar.gz -C dist/linux/amd64 $(APPNAME)
#	mkdir -p dist/linux/i386  && GOOS=linux GOARCH=386 go build -o dist/linux/i386/$(APPNAME) ./src
#	tar -cvzf dist/$(APPNAME)-linux-i386-i386$(TAG).tar.gz -C dist/linux/i386 $(APPNAME)

