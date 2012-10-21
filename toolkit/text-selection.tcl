## Bindings for an advanced text selection system
## that works around the limitation of the 'sel' tag setting either (if raised)
## the standard selection color, or (if lowered) leaving the background color
## unchanged.
## This system provides a mechanism that scans, whenever the selection
## changes, the selected text for tag ranges of tags that set background
## colors, and apply special tags (named like 'mytag#sel') on the intersection
## of the 'sel' tag and the normal markup tag.
## To enable the described mechanism for a given text widget, add the
## string "TextSelMechanism" to its bindtags.
## Note that the 'mytag#sel' tags must be individually configured, either
## directly or by using [::tk_text::makeseltag mytag] which automatically
## calculates a "selected background" color for «mytag#sel» as a function
## of «mytag»'s background color.

namespace eval ::tk_text {}

bind TextSelMechanism <<Selection>> {::tk_text::selectionChange %W}

# This works around the many events that are generated when text is selected
# using the mouse: at every <Motion> event, two <<Selection>> events are
# issued; the first clears the selection, and the second creates the new selection
# — which is almost always identical to the one before it has been cleared.
# We store the last non-empty selection in a variable, and fire a 
# <<SelectionSettle>> event only when a new non-empty selection has been
# created, and when the selection is still empty after going into the idle loop.

set ::tk_text::lastselection [dict create]
proc ::tk_text::selectionChange {window} {
	if {![dict exists $::tk_text::lastselection $window]} {
		dict set ::tk_text::lastselection $window "unset"
	}
	set cur_selection [$window tag ranges sel]
	set script [list ::tk_text::selectionTest $window]
	after cancel $script
	if {$cur_selection == {}} {
		after idle $script
	} else {
		if {$cur_selection != [dict get $::tk_text::lastselection $window]} {
			dict set ::tk_text::lastselection $window $cur_selection
			event generate $window <<SelectionSettle>>
		}
	}
}

# This is the "after idle" handler that handles updating to an empty selection.
proc ::tk_text::selectionTest {window} {
	set cur_selection [$window tag ranges sel]
	if {$cur_selection == [dict get $::tk_text::lastselection $window]} return
	dict set ::tk_text::lastselection $window $cur_selection
	event generate $window <<SelectionSettle>>
}

bind TextSelMechanism <<SelectionSettle>> {::tk_text::selectionUpdateTags %W}

# This procedure does the actual work, creating the 'mytag#sel' ranges, while
# the other ones only make sure that it is called as seldom as possible.
proc ::tk_text::selectionUpdateTags {window} {
	puts "selection change @ $window: [$window tag ranges sel]"
	$window configure -background "#[format %06x [expr int(rand() * 2**24)]]"
}

pack [text .t -font "Monospace -16"]
bindtags .t [concat [bindtags .t] TextSelMechanism]
