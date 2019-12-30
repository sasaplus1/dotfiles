FROM ubuntu:latest

RUN apt update --yes && apt install --yes bash make

WORKDIR /root/.ghq/github.com/sasaplus1/dotfiles

COPY . .
