#!/usr/bin/wish8.5

## Make tclIndex accessible

# Relative path to tclIndex - needs to be updated (add/remove some ..)
#  whenever this script is moved into a different hierarchy level
set dir [file join [file dirname [info script]] .. ..]
source [file join $dir tclIndex]

ttk_useTheme clam
wm state . withdrawn
::tagsheet::gui::errorwindow /dev/null

bind .tagsheetw <Destroy> {destroy .}

after 2000 ::tagsheet::gui::mod-error
after 4000 ::tagsheet::gui::mod-success
after 6000 ::tagsheet::gui::mod-changed
after 8000 ::tagsheet::gui::mod-error
