#!/bin/bash

[ $# -eq 0 ] && ls ~/template_*
[ $# -eq 1 ] && vim ~/template_*${1}*
