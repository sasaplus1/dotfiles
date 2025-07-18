FROM ubuntu:latest@sha256:a08e551cb33850e4740772b38217fc1796a66da2506d312abe51acda354ff061

RUN apt-get update --yes && \
  apt-get install --yes bash make

WORKDIR /root/.ghq/github.com/sasaplus1/dotfiles

COPY . .
