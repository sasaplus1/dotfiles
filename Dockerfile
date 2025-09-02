FROM ubuntu:latest@sha256:f3b7f1bdfaf22a0a8db05bb2b758535fe0e70d82bea4206f7549f89aa12922f4

RUN apt-get update --yes && \
  apt-get install --yes bash make

WORKDIR /root/.ghq/github.com/sasaplus1/dotfiles

COPY . .
