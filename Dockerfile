FROM ubuntu:latest@sha256:c35e29c9450151419d9448b0fd75374fec4fff364a27f176fb458d472dfc9e54

RUN apt-get update --yes && \
  apt-get install --yes bash make

WORKDIR /root/.ghq/github.com/sasaplus1/dotfiles

COPY . .
