#!/usr/bin/wish8.5

## Make tclIndex accessible

# Relative path to tclIndex - needs to be updated (add/remove some ..)
#  whenever this script is moved into a different hierarchy level
set dir [file join [file dirname [info script]] .. ..]
source [file join $dir tclIndex]

ttk_useTheme clam
wm state . withdrawn
::tagsheet::gui::errorwindow \
	[file join [file dirname [info script]] tagsheets example.tagsheet]\
	2 "System error."

bind .tagsheetw <Destroy> {destroy .}

namespace import ::tcl::mathop::*
after 3000 ::tagsheet::gui::mod-error 2 {"I don't understand this."}
after 6000 ::tagsheet::gui::mod-success
after 9000 ::tagsheet::gui::mod-changed
after 12000 ::tagsheet::gui::mod-error 2 {"I still can't understand you."}
