FROM ubuntu:latest@sha256:353675e2a41babd526e2b837d7ec780c2a05bca0164f7ea5dbbd433d21d166fc

RUN apt-get update --yes && \
  apt-get install --yes bash make

WORKDIR /root/.ghq/github.com/sasaplus1/dotfiles

COPY . .
