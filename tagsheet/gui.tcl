namespace eval ::tagsheet::gui {}

## Builds an error window and immediately returns
proc ::tagsheet::gui::errorwindow {filename} {
	# toplevel window
	set w .tagsheetw
	destroy $w
	ttk_toplevel $w
		wm title $w "Error in tagsheet"
		wm minsize $w 500 100
	# info labels
	ttk::label $w.caption -text "Could not read style definitions from file $filename:"
		$w.caption configure -font TkCaptionFont
		pack $w.caption -anchor w -padx 10 -pady 10 -fill x
	ttk::label $w.error -text "invalid bareword \"size\" in expression \"1.4 * size\";\nshould be ..."
		$w.error configure -font TkFixedFont -relief sunken
		pack $w.error -anchor w -padx 10 -pady {0 10} -fill x
	ttk::label $w.advice -text [join [list "The contents of $filename are shown below." \
			"You can correct error(s) and retry evaluating the style definitions."]]
		pack $w.advice -anchor w -padx 10 -pady {0 10} -fill x
	foreach label [list $w.caption $w.error $w.advice] {
		$label configure -wraplength 480
	}
	# text field
	set tframe [ttk_text $w.text -relief flat -highlightthickness 0 -width 1 -height 10]
		pack $tframe -padx 10 -pady 1 -fill both -expand true
	ttk_text_scrollbar $w.text on
	# buttons
	ttk::frame $w.buttons
		pack $w.buttons -padx 10 -pady 10
	ttk::button $w.reeval -text "Evaluate again" -default active -takefocus 0
	ttk::button $w.cancel -text "Cancel" -takefocus 0
	ttk::button $w.continue -text "Continue without saving" -takefocus 0
	ttk::button $w.saveandcont -text "Save tagsheet and continue" -default active -takefocus 0
		pack $w.reeval $w.cancel -in $w.buttons -side left -padx 2
		#grid $w.continue $w.saveandcont -in $w.buttons -row 1
}

## Procedures to modify the GUI after re-evaluating the tag definitions
proc ::tagsheet::gui::mod-error {} {
	set w .tagsheetw
	$w.caption configure -text "Error while re-evaluating style definitions:"
	pack $w.error -after $w.caption -anchor w -padx 10 -pady {0 10} -fill x
	pack forget $w.reeval $w.cancel $w.continue $w.saveandcont
	pack $w.reeval $w.cancel -in $w.buttons -side left -padx 2
}

proc ::tagsheet::gui::mod-success {} {
	set w .tagsheetw
	$w.caption configure -text "Style definitions evaluated without error."
	pack forget $w.error
	pack forget $w.reeval $w.cancel $w.continue $w.saveandcont
	pack $w.continue $w.saveandcont -in $w.buttons -side left -padx 2
}

proc ::tagsheet::gui::mod-changed {} {
	set w .tagsheetw
	pack forget $w.reeval $w.cancel $w.continue $w.saveandcont
	pack $w.reeval $w.cancel -in $w.buttons -side left -padx 2
}
