SHELL:=/bin/bash

build:
	docker build -t vmware-uploader .

shell:
	docker run -it --rm -v $(shell pwd):/tmp vmware-uploader /bin/sh

deploy:
	docker run -it --rm vmware-uploader
