namespace eval ::tagsheet {}
namespace eval ::tagsheet::priv {}

## Procedure used for normal cases, where tag definitions are made in a single
## tagsheet file. (For more complex cases, call init and evalfile manually.)

proc ::tagsheet::evalsinglefile {filename} {
	::tagsheet::init
	::tagsheet::evalfile $filename
	::tagsheet::round-values
	return [::tagsheet::getresults]
}

set ::tagsheet::priv::scriptdir [file dirname [info script]]

proc ::tagsheet::init {} {
	## (Re-)Creates the interpreters that will parse our tagsheets. The _outer_ interpreter
	## is going to [eval] the whole tagsheet, giving the attribute-definition parts of
	## [inlinetag], [linetype] and [default] statements to the _inner_ interpreter.
	catch {interp delete ::tagsheet::outer-interp}
	catch {interp delete ::tagsheet::inner-interp}
	interp create -safe ::tagsheet::outer-interp
	interp create -safe ::tagsheet::inner-interp
	# Hide unnecessary commands
	foreach command {after chan close eof fblocked fcopy fileevent flush \
	                     gets interp puts read rename seek trace update vwait} {
		::tagsheet::outer-interp hide $command
		::tagsheet::inner-interp hide $command
	}
	# Give them puts, flush and gets (note that the channel argument is gone).
	# Needed for end-user tagsheet debugging - don't remove them!
	foreach interp {::tagsheet::outer-interp  ::tagsheet::inner-interp} {
		$interp alias puts   puts stdout
		$interp alias flush  flush stdout
		$interp alias gets   gets stdin
	}
	# Give them a renamed proc command 'iproc', such that procedures defined inside 
	# child interpreters do not show up in tclIndex
	foreach interp {::tagsheet::outer-interp  ::tagsheet::inner-interp} {
		$interp eval {
			proc iproc {args} {
				proc {*}$args
	}	}	}
	
	## Give them all the commands necessary for evaluating tagsheets

	# this contains procedures linetype, default, inlinetag, listindents
	::tagsheet::outer-interp invokehidden source \
		[file join $::tagsheet::priv::scriptdir outer-interp.tcl]

	# this contains an unknown handler for aaa = bbb assignments, toggle, and more
	::tagsheet::inner-interp invokehidden source \
		[file join $::tagsheet::priv::scriptdir inner-interp.tcl]
	
	## Ability for the outer interpreter to evaluate code in the inner one:
	interp alias  ::tagsheet::outer-interp inner-eval      ::tagsheet::inner-interp eval
	## link attr_set from inner to outer interpreter:
	interp alias  ::tagsheet::inner-interp outer-attr_set  ::tagsheet::outer-interp attr_set
	## link attr_gettype from outer to inner interpreter:
	interp alias ::tagsheet::outer-interp attr_gettype  ::tagsheet::inner-interp attr_gettype
	# make cond() known to the outer interpreter
	::tagsheet::outer-interp alias  ::tcl::mathfunc::cond  ::tcl::mathfunc::cond
}

# For ::tagsheet::evalfile, see gui.tcl; unchecked_evalfile is called from there.

proc ::tagsheet::unchecked_evalfile {filename} {
	::tagsheet::outer-interp invokehidden source $filename
}

## Rounds all Number attributes inside 'outer-interp' to integers
proc ::tagsheet::round-values {} {
	::tagsheet::outer-interp eval {
		foreach dictionary {::defaults ::linetypes ::inlinetags} {
			dict for {key value} [set $dictionary] {
				if {$key in {size offset leftmargin leftmargin1 rightmargin \
				 topskip bottomskip lineskip bulletdistance}} {
					if {[string first {$} $value]==-1} {
						dict set $dictionary $key [expr {round($value)}]
					} else {
						dict set $dictionary $key "round($value)"
					}
	}	}	}	}
}

## Reads tag definitions out of the tagsheet interpreter
proc ::tagsheet::getresults {} {
	::tagsheet::outer-interp eval {
		dict create \
			defaults $::defaults \
			linetype_names $::linetype_names    linetypes $::linetypes \
			inlinetag_names $::inlinetag_names  inlinetags $::inlinetags \
			listindents $::listindents
	}
}
