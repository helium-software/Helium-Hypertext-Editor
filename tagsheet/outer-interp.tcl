# To be sourced into ::tagsheet::outer-interp
# The 'iproc' command is a synonym to 'proc' that avoids those procs showing up in tclIndex.

## Global variables:
#   ::context        tells attr_set from what kind of definition it is called
#   ::name           tells attr_set to which name the current definitions belong
#   ::dotattributes  dict with mapping linetype.attr -> value
#                     used to resolve "linetype.attr" references in attr_set [using string map]
#
#   ::defaults       dict with mapping attr -> value, contains definitions made in
#                     "default" statement(s)
#   ::linetypes      dict with mapping name -> [dict with mapping attr -> value], 
#                     contains definitions made in "linetype" statements
#   ::inlinetags     dict with mapping name -> [dict with mapping attr -> value_expr],
#                     contains definitions made in "inlinetag" statements
#
#   ::linetype_names   dict with mapping name -> displayname, for linetype styles only
#   ::inlinetag_names  dict with mapping name -> displayname, for inlinetag styles only
#
#   ::parent_refs    dict with mapping "parent.name" -> "$name" for inlinetags
foreach inline_attr {font color background size offset bold italic underline overstrike} {
	dict set ::parent_refs parent.$inline_attr $$inline_attr
}
#   ::listindents    list of the indentation distances from "listindents" command, like {6 4 3}
#   ::padding        dict like {x 5 y 4}, specifies distance of text content from widget border
#   ::selection      dict like {color #ccc alpha 0.85}, defines appearance of selection highlight
#   ::cursor         dict like {color #000 width 1 ontime 600 offtime 300}, defines appearance of cursor

iproc reset {} {
	set ::dotattributes [dict create]
	set ::defaults [dict create \
		font "Sans"  color black  background white  size 13     \
		bold 0  italic 0  offset 0  underline 0  overstrike 0   \
		leftmargin 0  leftmargin1 0  rightmargin 0  align left  \
		topskip 0  bottomskip 0  lineskip 0                     \
		bulletdistance 0  bullet ""  bulletcolor black          ]
	dict for {attr value} $::defaults {
		dict set ::dotattributes default.$attr $value
	}
	set ::linetypes [dict create]
	set ::inlinetags [dict create]
	set ::linetype_names [dict create]
	set ::inlinetag_names [dict create]
	set ::listindents 10
	set ::padding [dict create x 1 y 1]
	set ::selection [dict create color "#c3c3c3" alpha 1]
	set ::cursor [dict create color black width 2 ontime 600 offtime 300]
}

## Implementation of tagsheet user commands

iproc default {attribdefs} {
	set ::context default
	set ::name    default

	inner-eval {set ::MODE default}
	inner-eval [attribdef_subst $attribdefs]
}
iproc linetype {name displayname attribdefs} {
	set ::context linetype
	set ::name $name
	dict set ::linetype_names $name $displayname
	if {![dict exists $::linetypes $name]} {dict set ::linetypes $name [dict create]}

	inner-eval {set ::MODE linetype}
	inner-eval [attribdef_subst $attribdefs]
}
iproc inlinetag {name displayname attribdefs} {
	set ::context inlinetag
	set ::name $name
	dict set ::inlinetag_names $name $displayname
	if {![dict exists $::inlinetags $name]} {dict set ::inlinetags $name [dict create]}

	inner-eval {set ::MODE inlinetag}
	inner-eval [attribdef_subst $attribdefs]
}
iproc listindents {args} {
	# eliminate "syntactic sugar" dots
	if { [lindex $args end] in [list "..." "…"] } {
		set args [lrange $args 0 end-1]
	}
	# complain if there are no indent distances given at all
	if {$args==[list]} {
		error "no list indents specified: must be like \"listindents +6 +4 ...\""
	}
	# go through the remaining arguments, all should be like +<num>
	set result [list]
	foreach arg $args {
		set num [scan $arg "+%d"]
		if {$num=={{}} || $num<0} {
			error "bad argument format '$arg': must be +<num>, where <num> is non-negative"
		}
		lappend result $num
	}
	set ::listindents $result
}
# The rest of the user commands, which have very similar syntax,
# is implemented with this meta-programming:
# Argument syntax:
#   command name -attributes ?names type? ?names type? ...
iproc command {name -attributes args} {
	# collect the attribute names (without type info) into $all_names
	foreach {names type} $args {
		lappend all_attrs {*}$names
	}
	# define the user command procedure
	iproc $name {attribdefs} "
		set ::context Other
		set ::name $name
		
		inner-eval {set ::MODE Other}
		inner-eval \[attribdef_subst \$attribdefs\]
	"
	
	# define the attr_gettype subprocedure
	
	# Example: [command cursor -attributes color String {width ontime offtime} Number] results in
	# 	iproc attr_gettype_cursor {attr} {
	#		switch $attr {
	#			color	{return String}
	#			width - ontime - offtime	{return Number}
	#			default	{error "unknown attribute \"$attr\": must be color, width, ontime, or offtime"}
	#	}	}
	
	append body "switch \$attr \{\n"
	foreach {names type} $args {
		append body "	[join $names " - "]	\{return $type\}\n"
	}
	append body "	default \{"
		# error message
		append body {error "unknown attribute \"$attr\": must be }
		append body [join [lrange $all_attrs 0 end-1] ", "]
		if {[llength $all_attrs]>1} {append body ", or "}
		append body [lindex $all_attrs end]
	append body "\}\n\}"
	
	iproc attr_gettype_$name {attr} $body
}

command padding -attributes {x y} Number
command selection -attributes color String alpha Number
command cursor -attributes color String {width ontime offtime} Number
rename command "" ;# delete the "command" procedure


## Helper for tagsheet user commands

iproc attribdef_subst {attribdefs} {
	set attribdefs [uplevel #0 [list subst $attribdefs]]
	# make sure that attribdefs now do not contain any $var and [cmd] (search for $ [ ] )
	if {[string match {*[\[\]$]*} $attribdefs]} {
		error "attribute definition still contains \$ \[ \] after substitution"
	}
	return $attribdefs
}

## Gets type of an attribute
## (Also used by inner interpreter)

iproc attr_gettype {attr} {
	if {$::context == "Other"} {
		return [attr_gettype_$::name $attr]
	}
	switch $attr {
		font - color  - background             {return String}
		size - offset                          {return Number}
		bold - italic - underline - overstrike {return Flag}

		leftmargin - leftmargin1 - rightmargin - topskip - bottomskip - lineskip -
		bulletdistance
		 { if {$::context != "inlinetag"} {return Number} else {
			error "attribute \"$attr\" is not allowed in inlinetag definitions"
		 } }
		align - bullet - bulletcolor
		 { if {$::context != "inlinetag"} {return String} else {
			error "attribute \"$attr\" is not allowed in inlinetag definitions"
		 } }
	}
	error "unknown attribute \"$attr\""
}

#####################################################################

## Logic for setting attributes
## (Only called from inner interpreter)

iproc attr_set {attr expr} {
	## check if attr is valid in this context
	set type [attr_gettype $attr]
	## substitute "linetype.attr" and "attr" references with actual (numeric/literal) values
	switch $::context {
	"default" {
		# substitute "attr"
		set expr [string map $::defaults $expr]
	} "linetype" {
		# substitute "linetype.attr"
		set expr [string map $::dotattributes $expr]
		# substitute "attr" (references into the linetype just being defined)
		set expr [string map [dict get $::linetypes $::name] $expr]
	} "inlinetag" {
		# substitute "linetype.attr"
		set expr [string map $::dotattributes $expr]
		# substitute "parent.attr" and "attr"  (in the same step, since
		#  "parent.attr" is replaced with "$attr" which still contains "attr")
		set expr [string map [dict merge $::parent_refs [dict get $::inlinetags $::name]] $expr]
	} "Other" {
		# this handles all remaining commands, e.g. cursor, padding, ...
		# substitude "linetype.attr"
		set expr [string map $::dotattributes $expr]
		# substitute attributes like color, ontime, ... from e.g. $::cursor
		set expr [string map [set ::$::name] $expr]
	}}
	## handle "if" clause (1st part: split $expr)
	set if_pos [string first " if " $expr]
	if {$if_pos != -1} {
		set cond [string range $expr $if_pos+4  end]
		set expr [string range $expr 0    $if_pos-1]
	}
	## calculate the resulting attribute, depending on its type
	## (the variable "expr" is transformed and written back to itself)
	switch $type {
	String {
		# There are no operators defined for strings, except the "parasitic space operator"
		# which is handled correctly without intervention.
		# What we need to do is making sure that no list nesting occurs in our string values,
		# i.e. [font = "DejaVu Sans"] should be the same as [font = DejaVu Sans].
		catch { #over-safety, ignore errors if unbalanced braces ever happen to appear
			set expr [concat {*}$expr]
		}
		# Detect function calls cond() and alphablend(), and evaluate them
		foreach function {cond alphablend} {
			if {! [string match "${function}(*)" $expr]} continue
			set expr [translate_$function $expr]
			# if we can (no parent references), calculate $expr as an expression,
			if {[string first {$} $expr] == -1} {
				set expr [expr $expr]
			# otherwise run a test against sample default values:
			} else {
				set size 12; set offset 0
				set bold 0; set italic 0; set underline 0; set overstrike 0
				set font "Sans"; set color "#abcdef"; set background "#012345"
				if {[catch {expr $expr} result]} {
					if {[string match {can't parse color "*"} $result]} {
						error $result
					} else {
						error "invalid expression syntax in \"$function\" call"
			}	}	}
			break
		}
	} Number {
		# translate Unicode multiplication sign to *
		set expr [string map {"·" "*"} $expr]
		# if we can (no parent references), calculate $expr as an expression, 
		if {[string first {$} $expr] == -1} {
			set expr [expr $expr]
		# otherwise run a test against sample default values:
		} else {
			set size 12; set offset 0
			if {[catch {expr $expr} catchresult]} {error "invalid expression syntax:\n$catchresult"}
			# put expr in brackets for correct calculations in e.g. "aaa += 55; bbb = aaa * x"
			set expr "($expr)"
		}
	} Flag {
		# translate logical constants and operators to "C" style
		# (expr does not provide calculations with yes and friends)
		set expr [string map {" xor " ^ " and " & " or " | "not " !
			yes 1 no 0 on 1 off 0 true 1 false 0} $expr]
		# if we can (no parent references), calculate $expr as an expression,
		if {[string first {$} $expr] == -1} {
			set expr [expr $expr]
		# otherwise run a test against sample default values:
		} else {
			set bold 0; set italic 0; set underline 0; set overstrike 0
			if {[catch {expr $expr}]} {error "invalid expression syntax"}
			# put expr in brackets for correct calculations in e.g. "aaa toggle; bbb = aaa & x"
			set expr "($expr)"
		}
	}}
	## handle "if" clause (2nd part)
	if {$if_pos != -1} {
		set cond [translate_condition $cond]
		# if we can (no parent references), calculate $cond and abort if it isn't true
		if {[string first {$} $cond] == -1} {
			set cond [expr $cond]
			if {!$cond} {return}
		# otherwise [occurs only in inlinetag blocks] run a test against sample default values:
		} else {
			set size 12; set offset 0
			set bold 0; set italic 0; set underline 0; set overstrike 0
			set font "Sans"; set color "#abcdef"; set background "#012345"
			if {[catch {expr $cond}]} {
				error "invalid expression syntax in \"if\" condition"
			}
		# and include $cond into $expr:
		# (we can't abort setting the attribute inside our expression, so
		#  if the condition is false, take the parent attribute - or the result
		#  of the previous assignments)
		# For the latter case, consider:
		# 	color = blue if parent.color = black
		# 	color = black if parent.color = blue
		# These two lines should work like
		# 	color = cond(parent.color=black, blue, parent.color=blue, black)
		# Without the following $else_value setting, the second assignment
		# would completely supersede the first.
			if {[dict exists $::inlinetags $::name $attr]} {
				set else_value [dict get $::inlinetags $::name $attr]
			} else {
				set else_value "\$$attr"
			}
			if {$type == "String"} {
				set expr "(($cond) ? (\"$expr\") : $else_value)"
			} else {
				set expr "(($cond) ? ($expr) : $else_value)"
			}
		}
	}
	## store the resulting attribute ($expr) in the appropriate place
	switch $::context {
	"default" {
		dict set ::defaults $attr $expr
		dict set ::dotattributes default.$attr $expr
		# leftmargin -> leftmargin1 coupling:
		if {$attr=="leftmargin"} {
			dict set ::defaults leftmargin1 $expr
			dict set ::dotattributes default.leftmargin1 $expr
		}
	} "linetype" {
		dict set ::linetypes $::name $attr $expr
		dict set ::dotattributes $::name.$attr $expr
		# leftmargin -> leftmargin1 coupling:
		if {$attr == "leftmargin"} {
			dict set ::linetypes $::name leftmargin1 $expr
			dict set ::dotattributes $::name.leftmargin1 $expr
		}
	} "inlinetag" {
		# make "bare" string attributes work when $expr is
		# evaluated using the expr command
		# 	Note that the $expr has already been tested before,
		# 	so we don't need to initialize default attributes again.
		if {[catch {expr $expr}]} {
			set expr "\"$expr\""
		}
		dict set ::inlinetags $::name $attr $expr
	} "Other" {
		# set attribute in e.g. ::cursor
		dict set ::$::name $attr $expr
	}}
}


## Translation helper procedures for attr_set
## They translate conditions and function calls from "tagsheet syntax"
## (less quotes, different operators) to Tcl expressions.

## Used for "if" clauses, and in translate_cond (see below).
iproc translate_condition {cond} {
	# translate logical operators and constants to "C" style
	# (expr does not provide calculations with yes and friends)
	set cond [string map {
		" xor " ^  " and " &  " or " |  "not " !
		" = " ==  ≠ !=  ≥ >=  ≤ <=
	} $cond]
	foreach {word value} {yes 1 no 0 on 1 off 0 true 1 false 0} {
		# The following approach with regsub word-start and word-end marks
		# avoids e.g. "Caslon" being substituted with "Casl1".
		set cond [regsub -all "\[\[:<:\]\]$word\[\[:>:\]\]" $cond $value]
	}
	# quote anything that looks like a string (meaning of the regular expression:
	#  Match a sequence of "non-operator-sign" characters whose first is not a digit.
	#  Additionally, the regexp takes care of omitting leading/trailing spaces.)
	#  Words that start with " or $ are left unchanged.
	set cond [regsub -all \
		{(^|[^$])([[:<:]][^-+*/%~!=<>&|?:^0-9"][^-+*/%~!=<>&|?:^]+[[:>:]])} \
		$cond {\1"\2"}]
	return $cond
}

iproc translate_cond {expr} {
	set arguments [string range $expr 5 end-1]
	set arguments [split $arguments ","]
	if {[llength $arguments]&1} {
		set arguments [linsert $arguments end-1 true]
	}
	set expr "cond("
	foreach {condition value} $arguments {
		set condition [translate_condition [string trim $condition]]
		
		set value [string trim $value]
		set startq_missing [expr {[string index $value 0]!="\""}]
		set endq_missing [expr {[string index $value end]!="\""}]
		if {$startq_missing && $endq_missing} {
			set value "\"$value\""
		} elseif {$startq_missing ^ $endq_missing} {
			error "unbalanced quotes in cond() body"
		}
		
		if {$expr!="cond("} {append expr ", "}
		append expr "$condition, $value"
	}
	append expr ")"
	return $expr
}

iproc translate_alphablend {expr} {
	set arguments [string range $expr 11 end-1]
	set arguments [split $arguments ","]
	foreach i {0 1} {
		set argument [string trim [lindex $arguments $i]]
		set startq_missing [expr {[string index $argument 0]!="\""}]
		set endq_missing [expr {[string index $argument end]!="\""}]
		if {$startq_missing && $endq_missing} {
			lset arguments $i "\"$argument\""
		} elseif {$startq_missing ^ $endq_missing} {
			error "unbalanced quotes in alphablend() body"
	}	}
	set expr "alphablend([lindex $arguments 0], [lindex $arguments 1], [lindex $arguments 2])"
	return $expr
}
