FROM alpine:edge

MAINTAINER docker@stefan-van-essen.nl

ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' TERM='xterm'

RUN apk -U upgrade && mkdir /app

COPY runas /bin/
