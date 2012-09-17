namespace eval ttk_fixes {}

set_ifnotexists ::ttk_fixes::texts [list]

## As there is no themed text widget, we must use the following helper to
## create a text widget with a more "modern" feeling.
## It creates the text widget as $windowpath and packs it into a ttk_frame
## whose path ist ${windowpath}_frame  (must not be already in use!)
## Return value: window path of the surrounding frame (needed for geometry
## management)
proc ttk_text {windowpath args} {
	lappend ::ttk_fixes::texts $windowpath
	set framepath ${windowpath}_frame
	ttk::frame $framepath
	text $windowpath {*}$args
		pack $windowpath -in $framepath -fill both -expand true
		bindtag_add $windowpath ttk_text
	# call theme-specific text configurator
	::ttk_fixes::text.[ttk_currentTheme] $windowpath
	return $framepath
}
bind ttk_text <Destroy> {lremoveitem ::ttk_fixes::texts %W}

## Procedure to add/remove a vertical scrollbar to a textwidget created with ttk_text
proc ttk_text_scrollbar {windowpath flag} {
	set scrollbar ${windowpath}_frame.vscroll
	if {$flag} {
		destroy $scrollbar
		ttk::scrollbar $scrollbar -orient vertical
		pack $windowpath -side left
		pack $scrollbar -side right -fill y
		$windowpath configure -yscrollcommand [list $scrollbar set]
		$scrollbar configure -command [list $windowpath yview]
	} else {
		destroy $scrollbar
		$windowpath configure -yscrollcommand ""
	}
	# call theme-specific text configurator
	::ttk_fixes::text.[ttk_currentTheme] $windowpath
}

## Theme-specific text configurators
# Clam
proc ::ttk_fixes::text.clam {textwidget} {
	set frame ${textwidget}_frame
	$textwidget configure -border 0 -highlightthickness 0
	$frame configure -relief solid
	set scrollbar $frame.vscroll
	if {[winfo exists $scrollbar]} {
		pack configure $textwidget -padx {1 0} -pady 1
		pack configure $scrollbar -padx 0 -pady 0
	} else {
		pack configure $textwidget -padx 1 -pady 1
	}
}
# Classic
proc ::ttk_fixes::text.classic {textwidget} {
	$textwidget configure -border 2 -relief sunken -highlightthickness 1
	pack configure $textwidget -padx 0 -pady 0
	set frame ${textwidget}_frame
	$frame configure -relief flat
	set scrollbar $frame.vscroll
	if {[winfo exists $scrollbar]} {
		pack configure $scrollbar -padx {2 0} -pady 1
	}
}
# Alt (near-Windows 95)
proc ::ttk_fixes::text.alt {textwidget} {
	set frame ${textwidget}_frame
	$textwidget configure -border 0 -highlightthickness 0
	$frame configure -relief sunken
	set scrollbar $frame.vscroll
	if {[winfo exists $scrollbar]} {
		pack configure $textwidget -padx {2 1} -pady 2
		pack configure $scrollbar -padx 0 -pady 0
	} else {
		pack configure $textwidget -padx 2 -pady 2
	}
}
# Default
proc ::ttk_fixes::text.default {textwidget} {
	$textwidget configure -border 1 -relief sunken -highlightthickness 0
	pack configure $textwidget -padx 0 -pady 0
	set frame ${textwidget}_frame
	$frame configure -relief flat
	set scrollbar $frame.vscroll
	if {[winfo exists $scrollbar]} {
		pack configure $scrollbar -padx 0 -pady 0
	}
}
