#!/bin/sh

awk 'NR>4{if($1 ~ /[a-zA-Z]+/)print}' FINJBS_9937_ALD.xls >| junkbob
