namespace eval ::tagsheet {}

proc ::tagsheet::init {} {
	catch {interp delete ::tagsheet::outer-interp}
	catch {interp delete ::tagsheet::inner-interp}
	## Create the interpreters that will parse our tagsheets. The _outer_ interpreter
	## is going to [eval] the whole tagsheet, giving the attribute-definition parts of
	## [inlinetag], [linetype] and [default] statements to the _inner_ interpreter.
	interp create -safe ::tagsheet::outer-interp
	interp create -safe ::tagsheet::inner-interp
	# hide unnecessary commands
	foreach command {after chan close eof fblocked fcopy fileevent flush \
	                     gets interp puts read rename seek trace update vwait} {
		::tagsheet::outer-interp hide $command
		::tagsheet::inner-interp hide $command
	}
	# give them puts, flush and gets (note that the channel argument is gone)
	# Needed for end-user tagsheet debugging - don't remove them!
	foreach interp {::tagsheet::outer-interp  ::tagsheet::inner-interp} {
		$interp alias puts   puts stdout
		$interp alias flush  flush stdout
		$interp alias gets   gets stdin
	}
	## Commands implemented in the outer interpreter
	::tagsheet::outer-interp eval {
	 proc default {attribdefs} {
		# body
	 }
	 proc linetype {name displayname attribdefs} {
		# body
	 }
	 proc inlinetag {name displayname attribdefs} {
		# body
	 }
	 proc listindents {num args} {
		# body
	 }
	}
	## The inner interpreter implements only assigment statements like aaa = bbb ?if ccc?,
	## that will all be caught by the following unknown handler:
	::tagsheet::inner-interp eval {
	 proc unknown {args} {
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
	 proc attr_error {} {
		error [join [list "bad attribute assignment: must be" \
		                  "attr = expr | attr ++ | attr -- | attr toggle"]]
	 }
	 # implement "attr toggle"
	 proc attr_toggle {attr} {
		puts "attr_toggle $attr"
	 }
	 # implement "attr ++" and "attr --"
	 proc attr_incr {attr plusminus} {
		puts "attr_incr $attr $plusminus"
	 }
	 # implement "attr += expr" and -=, *=, /=
	 proc attr_setop {attr op expr} {
		set op [string index $op 0]  ;# discard trailing '=' sign
		if {"inlinetag" == "inlinetag"} {
			attr_set $attr [list parent.$attr $op $expr]
		} else {
			error "+= -= *= and /= are only allowed in inlinetag definitions"
		}
	 }
 	 # implement "attr = expr"
 	 proc attr_set {attr expr} {
 		puts "attr_set $attr <TO> $expr"
 	 }
	}
}
::tagsheet::init

