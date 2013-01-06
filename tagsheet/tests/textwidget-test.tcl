#!/usr/bin/wish8.5

## Make tclIndex accessible

# Relative path to tclIndex - needs to be updated (add/remove some ..)
#  whenever this script is moved into a different hierarchy level
set dir [file join [file dirname [info script]] .. ..]
source [file join $dir tclIndex]

ttk_useTheme clam
tagsheet::init

## Prepare arithmetic operators as commands
namespace import ::tcl::mathop::*

## Set up the widgets
pack [ttk::panedwindow .pw] -fill both -expand true -padx 1 -pady 1
.pw add [ttk_text .tagsheet -height 20]
ttk_text_scrollbar .tagsheet on
.pw add [ttk::frame .frame]
pack [ttk_text .rendering -height 7] -in .frame -fill both -expand true 
ttk_text_scrollbar .rendering on
ttk::button .renderbutton -text "Update (Ctrl-R)" -takefocus 0
pack .renderbutton -in .frame -side top -anchor e -before .rendering_frame -pady {0 2}
ttk::style configure TButton -padding 0

bind . <Control-KeyPress-r> {.renderbutton state pressed}
bind . <Control-KeyPress-r><KeyRelease-r> {.renderbutton state !pressed; .renderbutton invoke;}

.renderbutton configure -command {puts "renderbutton-press [expr rand()]"}

## Initial tagsheet
.tagsheet insert end \
{default {
	leftmargin = 10
	rightmargin = 10
	font = Century Schoolbook L
	size = 10
	# background = black; color = #ccc
}
selection {
	# color = red
}
padding {
	# x = 10; y = 10
}
linetype fline "Formatted Line" {
	font = Sans; bold = on; italic = on
	topskip = 6; bottomskip = 4
	size = default.size * 2
	align = center
}
listindents +9 +18
linetype list "List element" {
	leftmargin = 20
	bullet = #
	bulletcolor = orange
	bulletdistance = 10
}
inlinetag span "Inline span" {
	size += 3
	italic toggle
	bold = not italic
}
}
## evaluate it (and make a procedure for later use)
proc reload_tagsheet {} {
	tagsheet::outer-interp eval reset
	tagsheet::outer-interp eval [.tagsheet get 1.0 end]
	set ::tagsheet [tagsheet::getresults]
}
reload_tagsheet

## create tags from tagsheets (and make procedure)
proc configure_tags {} {
	set w .rendering
	set t $::tagsheet
	tagsheet::textwidget_configure $w $t
	tagsheet::linetag_configure $w $t : RootTag = default
	tagsheet::linetag_configure $w $t : fline = fline
	tagsheet::linetag_configure $w $t : list1 = list INDENT 1
	tagsheet::bullettag_configure $w $t : list1.bullet = list Indent 1
	tagsheet::linetag_configure $w $t : list2 = list Indent 2
	tagsheet::bullettag_configure $w $t : list2.bullet = list INDENT 2

	tagsheet::inlinetag_configure $w $t : span0 = span PARENT RootTag
	foreach i {1 2 3 4 5} {
		tagsheet::inlinetag_configure $w $t : span$i = span PARENT span[- $i 1]
	}
}
configure_tags

## create textfield content
proc insert_text {} {
	set w .rendering
	set t $::tagsheet
	$w delete 1.0 end
	$w insert end \
		"This is a default-style paragraph with multi-line text. " RootTag \
		"The quick brown fox jumps over the lazy dog and the rusty rail. " RootTag \
		"The lazy dog eats my big sphinx of quartz.\n" RootTag
	$w insert end \
		"Formatted line (fline).\n" fline
	$w insert end \
		[tagsheet::makebullet $t : list 1] {list1 list1.bullet} \
		"First outer list item: one two three four five six seven eight nine ten eleven" list1 \
		" twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty\n" list1
	$w insert end \
		[tagsheet::makebullet $t : list 1] {list2 list2.bullet} \
		"Inner list item: Lorem ipsum dolor sit amet, consectetur adipiscing elit." list2 \
		" Phasellus nunc sapien, porta id pellentesque at, elementum et felis.\n" list2
	$w insert end \
		[tagsheet::makebullet $t : list 2] {list1 list1.bullet} \
		"Second outer list item\n" list1
	$w insert end \
		"Inline formatting: " RootTag "span " {RootTag span0} "span " {RootTag span1} \
		"span " {RootTag span2} "span." {RootTag span3}
}
insert_text

## Update button
.renderbutton configure -command {reload_tagsheet; configure_tags; insert_text}
