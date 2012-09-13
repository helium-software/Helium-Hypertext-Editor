# To be sourced into ::tagsheet::inner-interp
# The 'iproc' command is a synonym to 'proc' that avoids those procs showing up in tclIndex.

## The inner interpreter implements only assigment statements like aaa = bbb ?if ccc?,
## that will all be caught by the following unknown handler:

iproc unknown {args} {
	# minimum argument count is 2, for "attr toggle" and "attr ++" etc.
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
	# match against "attr ++"
	if {$arglen == 2 && $arg2 == "++"} {
		attr_incr $arg1 + ; return
	}
	# match against "attr --"
	if {$arglen == 2 && $arg2 == "--"} {
		attr_incr $arg1 - ; return
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
	error [join [list "bad attribute assignment: must be attr = expr |" \
	                  "attr += -= *= /= expr | attr ++ | attr -- | attr toggle"]]
}
# implement "attr toggle"
iproc attr_toggle {attr} {
	puts "attr_toggle $attr"
}
# implement "attr ++" and "attr --"
iproc attr_incr {attr plusminus} {
	puts "attr_incr $attr $plusminus"
}
# implement "attr += expr" and -=, *=, /=
iproc attr_setop {attr op expr} {
	set op [string index $op 0]  ;# discard trailing '=' sign
	if {"inlinetag" == "inlinetag"} {
		attr_set $attr [list parent.$attr $op ( {*}$expr )]
	} else {
		error "+= -= *= and /= are only allowed in inlinetag definitions"
	}
}
# implement "attr = expr"
iproc attr_set {attr expr} {
	puts "attr_set $attr <TO> $expr"
}
