#!/bin/bash

docker buildx build --platform linux/amd64 --tag ghcr.io/jhordies/mods:code-server-virtualhere --push .