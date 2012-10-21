## Bindings for an advanced text selection system
## that works around the limitation of the 'sel' tag imposing either (if raised)
## the standard selection color, or (if lowered) leaving the background color
## unchanged.
## This system provides a mechanism that scans, whenever the selection changes,
## the selected text for tag ranges of tags that set background colors, and
## apply special tags (named like 'mytag#sel') on the intersection of the 'sel'
## tag and the normal markup tag.
## To enable the described mechanism for a given text widget, add the string
## "TextSelMechanism" to its bindtags.
## Note that the 'mytag#sel' tags must be individually configured, either
## directly or by using [::tk_text::makeseltag $widget mytag] which automatically
## calculates a "selected background" color for «mytag#sel» as a function of
## «mytag»'s background color.
##
## Note:
## 1) You should always set the -selectbackground and -inactiveselectbackground
##    options of a text widget to the same color (don't set the selection color
##    only via the -background option of the 'sel' tag), because the #sel tags
##    don't synchronize to the changed selection color at focus-out, so the
##    "illusion" of an alpha-transparent selection would be lost.
## 2) If you have a tag with white or nearly white background color, you will
##    notice that the color chosen by the procedure ::tk_text::makeseltag will
##    be lighter than the selection outside of tags - this one is actually not
##    alpha-blended to the white widget background, because it is itself the
##    _source_ for alpha blending.
##    This "problem" has been considered as a somewhat useful feature, since
##    it helps spotting ranges of tags with nearly invisible background colors
##    while selecting text. If you don't like it, either increase the alpha
##    opacity, or adjust the selection background to a blend of "pure selection
##    color" with white, after all the mytag#sel tags have been created.
##    (Don't rewrite the blending calculation on your own: Use a dummy tag,
##     set its background color to white, and calculate its selected color
##     with ::tk_text::makeseltag. Then set the -selectbackground attributes
##     from that color.)

namespace eval ::tk_text {}

#==============================================================================

# The following part works around the many events that are generated when text
# is selected using the mouse: at every <Motion> event, two <<Selection>> events
# are issued; the first clears the selection, and the second creates the new
# selection — which is almost always identical to the one before it has been
# cleared.
# We store the last non-empty selection in a variable, and fire a 
# <<SelectionSettle>> event only when a new non-empty selection has been
# created, and when the selection is still empty after going into the idle loop.

bind TextSelMechanism <<Selection>> {::tk_text::selectionChange %W}

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

#==============================================================================

# The next procedure does the actual work, creating the 'mytag#sel' ranges,
# while the ones above only make sure that it is called as seldom as possible.

set ::tk_text::appliedseltags [dict create]

proc ::tk_text::selectionUpdateTags {window} {
	
	# remove all ranges of x#sel tags applied in the previous call of this proc
	if {[dict exists $::tk_text::appliedseltags $window]} {
		foreach tag [dict get $::tk_text::appliedseltags $window] {
			$window tag remove $tag 1.0 end
		}
	}
	dict set ::tk_text::appliedseltags $window [list]

	# apply x#sel tags newly
	foreach {startidx endidx} [$window tag ranges sel] {
		set tagstarts [dict create]
		# process implicit "tagon"s at start of selection range
		foreach tag [$window tag names $startidx] {
			if {$tag=="sel"} continue
			if {[$window tag cget $tag -background]==""} continue
			dict set tagstarts $tag $startidx
		}
		foreach {key tag index} [$window dump -tag $startidx $endidx] {
			if {$tag=="sel"} continue
			if {[$window tag cget $tag -background]==""} continue

			switch $key "tagon" {
				dict set tagstarts $tag $index
			} "tagoff" {
				set tagend $index
				if {[dict exists $tagstarts $tag]} {
					set tagstart [dict get $tagstarts $tag]
					dict unset tagstarts $tag
				} else {set tagstart $startidx}
				dict unset tagstarts $tag
				$window tag add "$tag#sel" $tagstart $tagend
				dict lappend ::tk_text::appliedseltags $window "$tag#sel"
			}
		}
		# process implicit "tagoff"s at end of selection range
		dict for {tag tagstart} $tagstarts {
			$window tag add "$tag#sel" $tagstart $endidx
			dict lappend ::tk_text::appliedseltags $window "$tag#sel"
		}
	}
}

#==============================================================================

# The procedure below creates tags for selected text, varying the color from the
# base tag via alpha blending.

# Helper image for reading color strings (like "yellow" or "#fcd") into R/G/B values
image create photo ::tk_text::testphoto -width 1 -height 1

proc ::tk_text::makeseltag {widget tagname {alpha 0.75}} {
	# Optional third parameter alpha:
	#  opacity of selection, laid "above" the colored tag

	set tagcolor [$widget tag cget $tagname -background]
	if {$tagcolor==""} return
	
	# convert (eventually named) color to R/G/B numbers in 0..255
	testphoto put $tagcolor
	lassign [testphoto get 0 0] tagR tagG tagB
	
	# get the plain selection color from the "sel" tag, convert it to R/G/B too
	testphoto put [$widget tag cget sel -background]
	lassign [testphoto get 0 0] selR selG selB
	
	# calculate the specific selection color with alpha blending
	set tagR [expr {round($alpha*$selR + (1-$alpha)*$tagR)}]
	set tagG [expr {round($alpha*$selG + (1-$alpha)*$tagG)}]
	set tagB [expr {round($alpha*$selB + (1-$alpha)*$tagB)}]
	
	# create the specific selection tag
	$widget tag configure "$tagname#sel" -background \
		[format "#%02x%02x%02x" $tagR $tagG $tagB]
	$widget tag raise "$tagname#sel"
	
	# utility: return the name of the tag just created
	return "$tagname#sel"
}
