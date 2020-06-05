CPUS:=$(shell grep -c ^processor /proc/cpuinfo)
MAKEFLAGS += --jobs=$(CPUS)

LIST:=  $(sort $(wildcard m4/*.m4))
dir:=./

dockerfiles:
	for i in $(LIST); do \
		m4 -I $(dir)/inc $(dir)"$$i" | awk 'NF' > `echo $${i##*/} | sed "s/.m4//"` ; \
	done

docker-build:
	for i in $(LIST); do \
		docker build --squash -q -t youmad/php:`echo $${i##*/} | sed "s/.m4//"` -f `echo $${i##*/} | sed "s/.m4//"` . ;\
		echo "finished: $${i##*/}" ;\
	done

docker-build-one:
	docker build --squash -t youmad/php:`echo $${image##*/} | sed "s/.m4//"` -f `echo $${image##*/} | sed "s/.m4//"` . ;\

docker-push:
	for i in $(LIST); do \
		docker push youmad/php:`echo $${i##*/} | sed "s/.m4//"` ;\
	done

docker-pull:
	docker pull php:7.4-cli-alpine3.11
	docker pull php:7.4-fpm-alpine3.11
	docker pull php:7.4-zts-alpine3.11
