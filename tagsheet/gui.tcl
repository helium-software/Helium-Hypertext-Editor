namespace eval ::tagsheet::gui {}

## Try to read and evaluate a tagsheet in the specified file, on error show
## a window that allows editing the tagsheet contents.
## This is the only procedure intended to be called from the outside.

proc ::tagsheet::gui::evalfile {filename} {
	::tagsheet::init
	set errordict [::tagsheet::catchevalfile $filename]
	if {[dict get $errordict status]=="success"} {
		return [::tagsheet::getresults]
	} else {
		::tagsheet::gui::errorwindow $filename [dict get $errordict line] [dict get $errordict result]
		tkwait variable ::tagsheet::gui::results
		set results $::tagsheet::gui::results
		destroy .tagsheetw ;# this destroys the original ::tagsheet::gui::results
		return $results
	}
}

## Builds an error window and immediately returns
proc ::tagsheet::gui::errorwindow {filename errorline errormsg} {
	# used for "saveandcont" procedure
	set ::tagsheet::filename $filename
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
	ttk::label $w.error -text "This field is intended to display the error message."
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
	bindtag_add $w.text TextSelMechanism
	::tk_text::setalpha $w.text 0.5
	$w.text tag configure errorline -background #ffcc44
	$w.text tag configure errorline#sel -background #ff9900
	catch {$w.text insert end [readfile_discardnl $filename]}
	bind $w.text <<Modified>> {if [.tagsheetw.text edit modified] ::tagsheet::gui::mod-changed}
	# buttons
	ttk::frame $w.buttons
		pack $w.buttons -padx 10 -pady 10
	ttk::button $w.reeval -text "Evaluate again" -default active -takefocus 0
	ttk::button $w.cancel -text "Cancel" -takefocus 0
	ttk::button $w.saveandcont -text "Save tagsheet and continue" -default active -takefocus 0
	ttk::button $w.cont -text "Continue without saving" -takefocus 0
		pack $w.reeval $w.cancel -in $w.buttons -side left -padx 2
	foreach button {reeval cancel saveandcont cont} {
		$w.$button configure -command ::tagsheet::gui::$button
	}
	# binding to $w.text instead of $w avoids getting a <Destroy> for each widget in $w
	bind $w.text <Destroy> ::tagsheet::gui::cancel
	# display error location and description
	$w.text see $errorline.0
	$w.text tag add errorline $errorline.0 [incr errorline].0
	$w.error configure -text $errormsg
}

## Procedures to modify the GUI after re-evaluating the tag definitions
proc ::tagsheet::gui::mod-error {errorline errormsg} {
	set w .tagsheetw
	$w.caption configure -text "Error while re-evaluating style definitions:"
	pack $w.error -after $w.caption -anchor w -padx 10 -pady {0 10} -fill x
	pack forget $w.reeval $w.cancel $w.cont $w.saveandcont
	pack $w.reeval $w.cancel -in $w.buttons -side left -padx 2
	$w.text configure -background white
	$w.text tag remove errorline 1.0 end
	$w.text see $errorline.0
	$w.text tag add errorline $errorline.0 [incr errorline].0
	$w.error configure -text $errormsg
}
proc ::tagsheet::gui::mod-success {} {
	set w .tagsheetw
	$w.caption configure -text "Style definitions evaluated without error."
	pack forget $w.error
	pack forget $w.reeval $w.cancel $w.cont $w.saveandcont
	pack $w.cont $w.saveandcont -in $w.buttons -side left -padx 2
	$w.text tag remove errorline 1.0 end
	$w.text configure -background #e0ffe0
	# prepare to trigger ::tagsheet::gui::mod-changed
	$w.text edit modified 0
}
proc ::tagsheet::gui::mod-changed {} {
	set w .tagsheetw
	pack forget $w.reeval $w.cancel $w.cont $w.saveandcont
	pack $w.reeval $w.cancel -in $w.buttons -side left -padx 2
	$w.text tag remove errorline 1.0 end
	$w.text configure -background white
}

## Button callbacks
proc ::tagsheet::gui::reeval {} {
	# quite similar to ::tagsheet::gui::evalfile
	::tagsheet::init
	set errordict [::tagsheet::catchevaldirect [.tagsheetw.text get 1.0 end-1c]]
	if {[dict get $errordict status]=="success"} {
		::tagsheet::gui::mod-success
	} else {
		::tagsheet::gui::mod-error [dict get $errordict line] [dict get $errordict result]
	}
}
proc ::tagsheet::gui::cancel {} {
	set ::tagsheet::gui::results {}
}
proc ::tagsheet::gui::saveandcont {} {
	if {[file exists $::tagsheet::filename]} {
		file rename -force $::tagsheet::filename "${::tagsheet::filename}~orig"
	}
	writefile_addnl $::tagsheet::filename [.tagsheetw.text get 1.0 end-1c]
	set ::tagsheet::gui::results [::tagsheet::getresults]
}
proc ::tagsheet::gui::cont {} {
	set ::tagsheet::gui::results [::tagsheet::getresults]
}
