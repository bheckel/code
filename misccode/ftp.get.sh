#!/bin/sh

# Remember that "prompt" is an alternative to "... -i ..."
ftp -i -n <<HERE
		open rdrtp
		user bqh0 Rfranc10
		mget test.dat
		close
		quit
HERE
