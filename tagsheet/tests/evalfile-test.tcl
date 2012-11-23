#!/usr/bin/wish8.5

## Make tclIndex accessible

# Relative path to tclIndex - needs to be updated (add/remove some ..)
#  whenever this script is moved into a different hierarchy level
set dir [file join [file dirname [info script]] .. ..]
source [file join $dir tclIndex]

ttk_useTheme clam

pack [ttk::labelframe .input -text Input:] -padx 2 -pady 2 -fill x
pack [ttk::label .input.command -text ::tagsheet::evalfile] -side left -padx 4
pack [ttk::entry .input.file] -side left -fill x -expand true
.input.file insert end [file join [file dirname script] tagsheets example.tagsheet]
pack [ttk::button .input.go -text "⏎" -width 0 -takefocus 0] -side left -padx 4 -pady 4

pack [ttk::labelframe .output -text Output:] -padx 2 -pady 2 -fill x
pack [ttk::label .output.text -font TkFixedFont -textvariable output -wraplength 600] -fill x

.input.go configure -command {
	set output [::tagsheet::evalfile [.input.file get]]
}
bind .input.file <Return> {
	.input.go invoke
}
