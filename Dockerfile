FROM debian:buster-slim

RUN apt-get update && \
	apt-get -y install \
	debootstrap \
	curl \
	qemu-user-static && \
	curl -L -o /tmp/apk-tools-static.apk http://alpine.mirror.far.fi/v3.10/main/x86_64/apk-tools-static-2.10.4-r2.apk && \
	cd /tmp && \
	tar xzf apk-tools-static.apk && \
	cp sbin/apk.static /usr/local/bin/ && \
	rm -rf /tmp/* && \
	rm -rf /var/lib/apt/lists/*

COPY scripts/* /usr/local/bin/

VOLUME /chroots /sysroots
