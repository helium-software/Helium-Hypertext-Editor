#!/usr/bin/wish8.5

## Make tclIndex accessible

# Relative path to tclIndex - needs to be updated (add/remove some ..)
#  whenever this script is moved into a different hierarchy level
set dir [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $dir tclIndex]

cd [file dirname [info script]]
ttk_useTheme clam

pack [text .tagsheet]
.tagsheet insert end [readfile broken.tagsheet]
pack [ttk::button .saveandeval -text "Save broken.tagsheet and eval"]
.saveandeval configure -command {
	writefile broken.tagsheet [.tagsheet get 1.0 end]
	::tagsheet::init
	set errordict [::tagsheet::catchevalfile broken.tagsheet]
	set display ""
	foreach {key value} $errordict {
	 	append display [list $key $value]\n
	}
	set display [string range $display 0 end-1]
	.result configure -text $display
	
	if {[dict get $errordict status]=="fail"} {
		set line [dict get $errordict line]
		.tagsheet tag add sel $line.0 $line.end
	} else {
		.tagsheet tag remove sel 1.0 end
	}
}
pack [ttk::label .resulttx -text "Result:"]
pack [ttk::label .result -font TkFixedFont -justify left -relief sunken] -fill x -padx 2 -pady 2
