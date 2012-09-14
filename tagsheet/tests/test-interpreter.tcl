#!/usr/bin/tclsh8.5

## Make tclIndex accessible

# Relative path to tclIndex - needs to be updated (add/remove some ..)
#  whenever this script is moved into a different hierarchy level
set dir [file join [file dirname [info script]] .. ..]
source [file join $dir tclIndex]

##
puts "\n   Test if the interpreters are initialized correctly:\n"

::tagsheet::init
tagsheet::outer-interp eval {puts "Hello from outer-interp"}
tagsheet::inner-interp eval {puts "Hello from inner-interp"}

##
puts "\n   Test the inner interpreter:\n"

proc feedInterp {script {interp ::tagsheet::inner-interp}} {
	if {[string index $script 0]=="\n"}   {set script [string range $script 1 end]}
	if {[string index $script end]=="\n"} {set script [string range $script 0 end-1]}
	puts -nonewline ">>: "
	puts [join [split $script \n] "\n>>: "]

	if [catch [list $interp eval $script] result] {set c E} else {set c o}

	if {$result==""} return
	puts -nonewline "$c: "
	puts [join [split $result \n] "\n$c: "]
}
feedInterp {Hello Interpreter; say something}
feedInterp {singleword}
feedInterp {three toggle words}
puts ""
tagsheet::outer-interp eval {
	reset; set ::context inlinetag; set ::name example; dict set ::inlinetags example [dict create]}
feedInterp {set MODE inlinetag}
feedInterp {bold toggle}
catch {tagsheet::inner-interp eval {bold toggle}} result extoptions
puts [join $extoptions]
feedInterp {font = "Some cool font"}
feedInterp {size += 45; offset /= 3 + 4; leftmargin /= 3}
feedInterp {offset = offset + 2}
feedInterp {blubb *= "Blubb"}
puts ""
tagsheet::outer-interp eval {set ::context linetype}
feedInterp {set MODE linetype}
feedInterp {bold toggle}
feedInterp {size += 45; offset /= 3 + 4; leftmargin /= 3}

##
puts "\n Test the outer interpreter \n"
feedInterp {
inlinetag test "Test tag" {
	bold toggle
	italic = yes
	size += 5
}} tagsheet::outer-interp
