#!/bin/ruby

require 'webrick'
include WEBrick

###myserver = HTTPServer.new(:Port => 8080, :DocumentRoot => Dir::pwd + "/temp")
# Serve all pages out of pwd
myserver = HTTPServer.new(:Port => 8080, :DocumentRoot => Dir::pwd)
myserver.start
# TODO how to stop it?
sleep 60
myserver.stop

# Then browse to http://localhost:8080/array.rb
