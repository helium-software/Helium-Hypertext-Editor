proc ::tagsheet::textwidget_configure {widget tagdict} {
	#
}
proc ::tagsheet::linetag_configure {widget tagdict : tagname = linetype} {
	keyword_check : =
}
proc ::tagsheet::inlinetag_configure {widget tagdict : tagname = inlinetag PARENT parenttag} {
	keyword_check : = PARENT
}

# examples
::tagsheet::textwidget_configure .f.text $::tagdict

::tagsheet::linetag_configure .f.text $::tagdict : MyTagName = heading1

::tagsheet::linetag_configure .f.text $::tagdict : MyTagname.bold = bold PARENT MyTagName
