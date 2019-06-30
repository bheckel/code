#!/bin/bash

cat /etc/*-release | grep VERSION | perl -pe 's/VERSION="//g'
