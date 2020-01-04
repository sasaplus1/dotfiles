FROM alpine:latest

RUN apk --no-cache add bash python3 python3-dev

RUN pip3 install --upgrade pip && pip3 install vim-vint

WORKDIR /mnt

ENTRYPOINT ["/usr/bin/vint"]

# vim:ft=dockerfile:
