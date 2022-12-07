#!/usr/bin/env bash

if [ $EUID -ne 0 ]; then
    exitWithMsg 1 "Run this as root or with sudo privilege."
fi