namespace eval ::tagsheet {}
namespace eval ::tagsheet::priv {}

set ::tagsheet::priv::scriptdir [file dirname [info script]]

proc ::tagsheet::init {} {
	## Creates the interpreters that will parse our tagsheets. The _outer_ interpreter
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
}
::tagsheet::init

