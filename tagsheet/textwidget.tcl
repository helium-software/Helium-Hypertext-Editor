# textwidget_configure — Applies attributes from a parsed tagsheet to a textwidget.
# Only those attributes are configured that are solely properties of the text widget itself,
# e.g. padding and cursor blink rate. The remaining attributes, e.g. left/right margins,
# cannot be set with textwidget_configure. They must be configured by creating
# a tag with linetag_configure, specifying a "linetype" argument of "default".
#
# Example:  ::tagsheet::textwidget_configure .f.text $::tagdict

proc ::tagsheet::textwidget_configure {widget tagdict} {
	## definitely sane defaults that don't relate to $tagdict settings
	$widget configure -wrap word
	## apply attributes from "padding" section
	$widget configure -padx [dict get $tagdict padding x] -pady [dict get $tagdict padding y]
	## apply attributes from "selection" section
	# The "alpha" attribute is used directly from the tagdict in the procedures
	# linetag_configure / inlinetag_configure, which create the corresponding #sel tags.
	set background [dict get $tagdict selection color]
	set foreground [dict get $tagdict default color]
	$widget configure -selectbackground $background -selectforeground $foreground \
		-inactiveselectbackground $background -inactiveselectbackground $foreground
	## apply attributes from "cursor" section
	$widget configure \
		-insertbackground [dict get $tagdict cursor color] \
		-insertwidth [dict get $tagdict cursor width] \
		-insertontime [dict get $tagdict cursor ontime] \
		-insertofftime [dict get $tagdict cursor offtime] \
		-insertborderwidth 0
}

# linetag_configure — Applies linetype attributes to a specified tag in a textwidget.
# Optionally, an indentation level can be given (for creating nested list items).
# If the "linetype" argument has a value of "default", the settings of the "default"
# section in the tagsheet are applied.
# Examples:
# ::tagsheet::linetag_configure .f.text $::tagdict : RootTag = default
# ::tagsheet::linetag_configure .f.text $::tagdict : MyTagName = heading1
# ::tagsheet::linetag_configure .f.text $::tagdict : MyTagNameB = listitem indent 1

proc ::tagsheet::linetag_configure {widget tagdict : tagname = linetype {INDENT INDENT} {indent 0}} {
	keyword_check : = INDENT
	## Figure out which settings to use (default or not)
	if {$linetype == "default"} {
		set attrs [dict get $tagdict default]
	} else {
		set attrs [dict get $tagdict linetypes $linetype]
	}
	## Calculate and set left margin
	set lindents [dict get $tagdict listindents]
	set len [llength $lindents]
	set indentmargin [+ {*}[lrange $lindents 0 $indent-1]]
	# [lrange] is quite forgiving and tolerates an end-index <0 or >length-1.
	# In the next step, we will add the appropriate number of "duplicates of the last value".
	set lastindent [lindex $lindents end]
	incr indentmargin [expr {max(0,$indent-$len) * $lastindent}]
	# The -lmargin property needs to take care of the bullet (if present).
	$widget tag configure $tagname \
		-lmargin2 [+ $indentmargin [dict get $attrs leftmargin]] \
		-lmargin1 [+ $indentmargin [dict get $attrs leftmargin1]]
	
	## Set those attributes that can just be taken over from the tagdict:
	foreach {key attr} {
		underline -underline  overstrike -overstrike
		offset -offset
		color -foreground  background -background
		#
		rightmargin -rmargin
		topskip -spacing1  bottomskip -spacing3  lineskip -spacing2
		align -justify
	} {
		set value [dict get $attrs $key]
		$widget tag configure $tagname $attr $value
	}
	## Set the font (attributes font, size, bold, italic)
	$widget tag configure $tagname -font [
		::tagsheet::create_fontstring \
			[dict get $attrs font] \
			[::tcl::mathfunc::round [dict get $attrs size]] \
			[dict get $attrs bold] [dict get $attrs italic]
	]
	## bonus for the caller
	return $tagname
}

# inlinetag_configure — Applies inlinetag attributes to a specified tag in a textwidget.
# Example: Creating tags for emphasized text inside bold text:
# ::tagsheet::inlinetag_configure .f.text $::tagdict : h1/bold = bold PARENT h1
# ::tagsheet::inlinetag_configure .f.text $::tagdict : h1/bold/emph = emph PARENT h1/bold

proc ::tagsheet::inlinetag_configure {widget tagdict : tagname = inlinetag PARENT parenttag} {
	keyword_check : = PARENT

	## Fetch attributes of parent tag
	foreach attr {underline overstrike offset background} {
		dict set parent_attrs $attr [$widget tag cget $parenttag -$attr]
	}
	dict set parent_attrs color [$widget tag cget $parenttag -foreground]
	set parent_attrs [dict merge $parent_attrs [::tagsheet::parse_fontstring \
		[$widget tag cget $parenttag -font] ]]

	## Apply inlinetag attribute set
	set tag_exprs [dict get $tagdict inlinetags $inlinetag]
	dict with $parent_attrs {
		# parent attributes are now available as $size etc.
		foreach attr [dict keys $parent_attrs] {
			# evaluate expressions like {$size + 4} from the tagsheet
			dict set new_attrs $attr [expr [dict get $tag_exprs $attr]]
	}	}

	## Set attributes of new tag
	foreach {key attr round} {
		underline -underline no  overstrike -overstrike no  offset -offset yes
		background -background no  color -foreground no
	} {
		set value [dict get $new_attrs $key]
		if {$round} {set value [::tcl::mathfunc::round $value]}
		$widget tag configure $tagname $attr $value
	}
	$widget tag configure $tagname -font [
		::tagsheet::create_fontstring \
			[dict get $new_attrs font] \
			[::tcl::mathfunc::round [dict get $new_attrs size]] \
			[dict get $new_attrs bold] [dict get $new_attrs italic]
	}
	## bonus for the caller
	return $tagname
}

# Creates a font string (like "{DejaVu Sans} 12 bold italic") from tagsheet style parameters
proc tagsheet::create_fontstring {font size bold italic} {
	set fontstring [list $font $size]
	if {$bold} {lappend fontstring "bold"}
	if {$italic} {lappend fontstring "italic"}
	return $fontstring
}
# Creates a font dict, like {font "DejaVu Sans" size 12 bold 1 italic 1}, from a font string
proc tagsheet::parse_fontstring {fontstring} {
	dict create font [lindex $fontstring 0] size [lindex $fontstring 1] \
		bold [::tcl::mathop::in bold $fontstring] italic [::tcl::mathop::in italic $fontstring]
}
