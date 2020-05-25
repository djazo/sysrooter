#!/usr/bin/env ash

docker run --rm -t --mount type=bind,source=$(pwd),target=/sysoots embeddedreality/apk:latest $@
