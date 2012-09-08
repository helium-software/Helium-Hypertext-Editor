#!/usr/bin/tclsh8.5

## Make tclIndex accessible

# Relative path to tclIndex - needs to be updated (add/remove some ..)
#  whenever this script is moved into a different hierarchy level
set dir [file join [file dirname [info script]] ..]
source [file join $dir tclIndex]

## Test if tclIndex is working

puts [namespace children ::]
