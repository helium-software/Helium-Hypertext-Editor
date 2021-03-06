# To be sourced into ::tagsheet::inner-interp
# The 'iproc' command is a synonym to 'proc' that avoids those procs showing up in tclIndex.

## The inner interpreter implements only assigment statements like aaa = bbb ?if ccc?,
## that will all be caught by the following unknown handler:

iproc unknown {args} {
	# minimum argument count is 2, for "attr toggle"
	set arglen [llength $args]
	if {$arglen < 2} {
		attr_error
	}
	set arg1 [lindex $args 0]
	set arg2 [lindex $args 1]
	# match against "attr toggle"
	if {$arglen == 2 && $arg2 == "toggle"} {
		attr_toggle $arg1 ; return
	}
	# other cases with two words are syntax errors
	if {$arglen == 2} {
		attr_error
	}
	# match against "attr = value"
	if {$arg2 == "="} {
		attr_set $arg1 [lrange $args 2 end] ; return
	}
	# match against "attr += value", "attr *= value" (integer operations)
	if {$arg2 in [list "+=" "-=" "*=" "/="]} {
		attr_setop $arg1 $arg2 [lrange $args 2 end] ; return
	}
	# other cases with any number of words are syntax errors
	attr_error
}

## Inner procedures used for interpreting attribute assignments. Tagsheets may contain
## calls to them that will succeed - it is bad behaviour but not dangerous at all.

# report syntax error
iproc attr_error {} {
	error [join [list "bad attribute assignment: must be attr = expr | attr += expr |" \
	                  "attr -= expr | attr *= expr | attr /= expr | attr toggle"]]
}
# implement "attr toggle"
iproc attr_toggle {attr} {
	if {[attr_gettype $attr]!="Flag"} {
		error "toggle is only allowed for Flag attributes"
	}
	if {$::MODE != "inlinetag"} {
		error "toggle is only allowed in inlinetag definitions"
	}
	attr_set $attr [list parent.$attr ^ 1]
}
# implement "attr += expr" and -=, *=, /=
iproc attr_setop {attr op expr} {
	if {[attr_gettype $attr]!="Number"} {
		error "$op is only allowed for Number attributes"
	}
	switch $::MODE \
		"inlinetag" {set ref "parent"} \
		"linetype" {set ref "default"} \
	default {
			error "$op is only allowed in inlinetag and linetype definitions"
	}
	set op [string index $op 0]  ;# discard trailing '=' sign
	attr_set $attr "$ref.$attr $op ($expr)"
}

## Connection to outer interpreter

# implements "attr = expr" (all cases like "toggle" and "+=" call this)
iproc attr_set {attr expr} {
	outer-attr_set $attr $expr
}
# gets type of an attribute
iproc attr_gettype {attr} {
	outer-attr_gettype $attr
}
