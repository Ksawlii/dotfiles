#!/bin/bash

# [
error()
{
    local RED="\033[0;31m"
    local RST="\033[0m"

    echo -e "${RED}ERROR: ${1}${RST}" >&2
    exit 1
}

info()
{
    echo -e "INFO: $1" >&2
}

warning()
{
    local ORG="\033[0;33m"
    local RST="\033[0m"

    echo -e "${ORG}WARN: ${1}${RST}" >&2
}
# ]
