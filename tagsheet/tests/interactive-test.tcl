#!/usr/bin/wish8.5

## Make tclIndex accessible

# Relative path to tclIndex - needs to be updated (add/remove some ..)
#  whenever this script is moved into a different hierarchy level
set dir [file join [file dirname [info script]] .. ..]
source [file join $dir tclIndex]

::tagsheet::init

## Prepare arithmetic operators as commands
namespace import ::tcl::mathop::*

### Build the GUI - Text frames and labels
ttk::style theme use clam
pack [ttk::panedwindow .pw] -expand true -fill both

foreach frame {tagsheet output} {
	.pw add [ttk::frame .$frame]
	grid [ttk::label .$frame.label -text "[string totitle $frame]:"] -pady 2 -row 0 -columnspan 2
	grid [text .$frame.text -height 10 -relief flat]  [ttk::scrollbar .$frame.sb] -row 1 -sticky nesw -pady 2
	grid columnconfigure .$frame 0 -weight 1; grid rowconfigure .$frame 1 -weight 1
	.$frame.sb configure -command [list .$frame.text yview]
	.$frame.text configure -yscrollcommand [list .$frame.sb set]
}

## Load Button
place [ttk::menubutton .load -text "Load" -takefocus 0] -in .tagsheet -x 2 -y 2 -anchor nw
	upvar #0 ::ttk::theme::clam::colors colors
	menu .load.menu -tearoff 0 \
		-background $colors(-lighter) -activebackground $colors(-darker) -activeborder 0 -relief solid
	.load configure -menu .load.menu
proc .load.update [list [list info_script [info script]]] {
	.load.menu delete 0 end
	foreach tagsheet [glob -nocomplain -directory [file dirname $info_script] *.tagsheet] {
		.load.menu add command -label [file rootname [file tail $tagsheet]] -command "
			[list load_tagsheet $tagsheet]
		"
	}
}
.load.update
bind .load <ButtonPress> .load.update

proc load_tagsheet {filename} {
	set ::filename $filename
	set channel [open $filename]
	.tagsheet.text delete 1.0 end
	.tagsheet.text insert end [read $channel]
	close $channel
	.refresh invoke
}
set ::filename ""

## Save Button
place [ttk::menubutton .save -text "Save as …" -takefocus 0] -in .tagsheet -relx 1 -x -2 -y 2 -anchor ne
	menu .save.menu -tearoff 0 \
		-background $colors(-lighter) -activebackground $colors(-darker) -activeborder 0 -relief solid
	.save configure -menu .save.menu
proc .save.update {args} {
	.save.menu delete 0 end
	if {$::filename != ""} {
		.save.menu add command -label $::filename -command "
			[list save_tagsheet $::filename]
		"
	}
	.save.menu add command -label "Other…" -command save_tagsheet
}
.save.update
bind .save <ButtonPress> .save.update

proc save_tagsheet {{filename ""}} {
	if {$filename == ""} {
		set filename [tk_getSaveFile -initialfile [file tail $::filename] -initialdir [file dirname $::filename]]
		if {$filename==""} return
	}
	set channel [open $filename w]
	puts -nonewline $channel [.tagsheet.text get 1.0 end-1char]
	close $channel
	set ::filename [file tail $filename]
}

## Refresh Button
place [ttk::button .refresh -text "Refresh (Ctrl-R)" -takefocus 0] -in .output -x 2 -y 2 -anchor nw
ttk::style configure Shrink.TButton -width "" -padding 0
.refresh configure -style Shrink.TButton; .save configure -style Shrink.TButton
ttk::style configure Shrink.TMenubutton -width 7 -padding 0
.load configure -style Shrink.TMenubutton
bind . <Control-KeyPress-r> {.refresh state pressed}
bind . <Control-KeyRelease-r> {.refresh state !pressed; .refresh invoke}

## Bind Refresh button to stylesheet interpreter
.refresh configure -command {
	::tagsheet::outer-interp eval reset
	::tagsheet::outer-interp eval [.tagsheet.text get 1.0 end]
	.output.text.render
}
## Radiobuttons for controlling output style
ttk::frame .outputstyle
place .outputstyle -in .output -relx 1 -x -2 -y 2 -anchor ne
grid [ttk::radiobutton .outputstyle.semantic] [ttk::radiobutton .outputstyle.dicts] -row 0
.outputstyle.semantic configure -text "Semantic"	 -variable outputstyle -value semantic \
	-takefocus 0 -command ".refresh invoke"
.outputstyle.dicts configure -text "Dicts" -takefocus 0 -variable outputstyle -value dicts \
	-takefocus 0 -command ".refresh invoke"
set outputstyle semantic


### Render the "parse tree" of the tagsheet to the .output.text widget
proc .output.text.render {} {
	.output.text.render.$::outputstyle [::tagsheet::getresults]
	.output.text delete end-1char
}
## Variant 1: Data-structure centered view
proc .output.text.render.dicts {resultdict} {
	.output.text delete 1.0 end
	dict_dump_init
	dict_dump $resultdict
	dict_dump_finish
}
.output.text tag configure emptystyle -font "Monospace -8" -background #ddd -foreground #555
.output.text tag configure keystyle -foreground #00c

proc dict_dump_init {} {
	set ::dict_dump_keylength [list 0 0 0 0]
}
proc dict_dump {dict {level 0} {maxlevel 3}} {
	if {$dict=={}} {
		.output.text insert end "{}" emptystyle "\n"
	} elseif {$level<$maxlevel && $dict!={} && [string is list $dict] && ([llength $dict] & 1)==0} {
		set lastkey [lindex $dict end-1]
		foreach {key value} $dict {
			# print the key, record its length
			.output.text insert end "${key}\t" keystyle
			set old_length [lindex $::dict_dump_keylength $level]
			if {[string length $key]>$old_length} {
				lset ::dict_dump_keylength $level [string length $key]
			}
			# additionally limit maxlevel to prevent "list-like" strings from being showed as sub-dicts
			set rec_maxlevel $maxlevel
			if {$level==0 && $key in [list "defaults" "inlinetag_names" "linetype_names"]} {set rec_maxlevel 2}
			if {$level==0 && $key=="listindents"} {set rec_maxlevel 1}
			if {$level==0 && $key in [list "padding" "selection" "cursor"]} {set rec_maxlevel 2}
			# print values or subdicts
			dict_dump $value [+ $level 1] $rec_maxlevel
			if {$key!=$lastkey} {
				.output.text insert end [string repeat \t [- $level 0]]
			}
		}
	} else {
		.output.text insert end "${dict}\n"
	}
}
proc dict_dump_finish {} {
	set tabs [list]
	set charwidth [font measure [.output.text cget -font] " "]
	set currtab 0
	foreach length $::dict_dump_keylength {
		incr currtab [* [+ $length 2] $charwidth]
		lappend tabs $currtab
	}
	.output.text configure -tabs $tabs
}
## Variant 2: Content-centered view
proc .output.text.render.semantic {resultdict} {
	.output.text delete 1.0 end
	.output.text insert end "inlinetag styles:\n" title
	dict with resultdict {}
	dict for {name attrs} $inlinetags {
		set displayname [dict get $inlinetag_names $name]
		print_style $name $displayname $attrs
	}
	.output.text insert end "linetype styles:\n" title
	dict for {name attrs} $linetypes {
		set displayname [dict get $linetype_names $name]
		print_style $name $displayname $attrs
	}
	.output.text insert end "Default style:\n" title
	print_attrs $defaults
	.output.text insert end "List indents (relative to each other): " title \
		"$listindents … [lindex $listindents end]\n"
	.output.text insert end "Padding: " title \
		"x=[dict get $padding x] y=[dict get $padding y]\n"
	.output.text insert end "Selection: " title \
		"color=[dict get $selection color] alpha=[dict get $selection alpha]\n"
	.output.text insert end "Cursor: " title \
		"color=[dict get $cursor color] width=[dict get $cursor width]  " "" \
		"ontime=[dict get $cursor ontime] offtime=[dict get $cursor offtime]"
}
.output.text configure -font "Monospace -10"
.output.text tag configure title -font "Sans -11 bold"
.output.text tag configure title-tt -font "Monospace -11 bold"
.output.text tag configure bold -font "Monospace -10 bold"

proc print_attrs {dict} {
	dict for {attr value} $dict {
		.output.text insert end "       $attr = $value\n"
	}
}
proc print_style {name displayname attrs} {
	.output.text insert end " $name" bold
	.output.text insert end " ($displayname)\n"
	print_attrs $attrs
}
