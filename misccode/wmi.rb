#!/bin/ruby

# View current Services via Windows Management Instrumentation

require 'win32ole'

mywmi = WIN32OLE.connect("winmgmts:\\\\.")
mywmi.InstancesOf("Win32_Service").each do |s|
  puts s.Caption + " : " + s.State
  puts s.Description
  puts
end
