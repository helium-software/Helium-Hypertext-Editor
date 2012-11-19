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

	# this contains procedures linetype, default, inlinetag, listindents, padding, selection, cursor
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

	## Set up the outer interpreter's data structures (default settings etc.):
	::tagsheet::outer-interp eval reset
}

proc ::tagsheet::evalfile {filename} {
	::tagsheet::outer-interp invokehidden source $filename
}

## Try to evaluate tagsheet code directly from the given argument
## (return value: see catchevalfile)
proc ::tagsheet::catchevaldirect {content} {
	# extra "eval" indirection, in order to have line info showing up as '("eval" body line 4)',
	# which is compatible to '(file "broken.tagsheet" line 4)'.
	# Code is first read into a variable to avoid getting the complete code into the stacktrace
	::tagsheet::outer-interp eval [list set catchevaldirect $content]
	set code [catch {::tagsheet::outer-interp eval {eval $catchevaldirect}} result details]
	::tagsheet::outer-interp eval [list unset catchevaldirect]
	::tagsheet::catcheval_common $code $result $details
}
## Try to read a tagsheet from $filename, producing useful error information when this fails.
## Returns on success: dict {status success}
## Returns on failure: dict {status fail result <error message> line <bad line# of tagsheet>}
## Returns on file not found: dict {status notfound}
proc ::tagsheet::catchevalfile {filename} {
	set code [catch {::tagsheet::outer-interp invokehidden source $filename} result details]
	::tagsheet::catcheval_common $code $result $details
}
proc ::tagsheet::catcheval_common {code result details} {
	if {$code==0} {
		return [dict create status success]
	} elseif {[dict get $details -errorcode]=="POSIX ENOENT {no such file or directory}"} {
		return [dict create status notfound]
	} else {
		# Find out the line where the error occurred
		# (needs tedious text processing, but only in the case
		#  when sourcing the tagsheet failed)
		set lines [split [dict get $details -errorinfo] \n]
		set lineinfo [lindex $lines end-4]
		# Now, lineinfo contains the interesting line, which looks like:
		#     (file "broken.tagsheet" line 1)
		set lineinfo [lindex [split $lineinfo] end]
		# discard ")" bracket
		set line [string range $lineinfo 0 end-1]
		
		# Make the guess smarter by looking at infos like:
		#     ("eval" body line 2)
		set lines [lrange $lines 0 end-5]
			# The line at index end-4 that gave $lineinfo might be another '("eval" body line n)'
			# (when called from catchevaldirect) and must be discarded.
		set evalhint [lindex [lsearch -all -inline $lines {    ("eval" body line *)}] end]
		if {$evalhint!=""} {
			set evalhint [lindex [split $evalhint] end]
			# discard ")" bracket and add to line
			incr line [string range $evalhint 0 end-1]
			# "eval body" lines are 1-based
			incr line -1
		}
	
		# fix ugly error format when expr fails
		if {[regexp {(invalid bareword ".*")\n(in expression ".*");\nshould be} $result "" resultA resultB]} {
			set result "$resultA $resultB"
		}
		return [dict create status fail  result $result  line $line]
	}
}

## Rounds all Number attributes inside 'outer-interp' to integers (deprecated)
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
			listindents $::listindents  padding $::padding \
			selection $::selection cursor $::cursor
	}
}
