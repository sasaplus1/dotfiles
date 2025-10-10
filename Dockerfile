FROM ubuntu:latest@sha256:59a458b76b4e8896031cd559576eac7d6cb53a69b38ba819fb26518536368d86

RUN apt-get update --yes && \
  apt-get install --yes bash make

WORKDIR /root/.ghq/github.com/sasaplus1/dotfiles

COPY . .
