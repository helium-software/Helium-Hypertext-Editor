# Procedure for matching keywords ("syntactic sugar" arguments) in command syntax

# For performance reasons, the calls to keyword_check should be commented out,
# once development has finished; except if the procedure that uses keywords can be
# called "from the outside".

# Each element of $args is expected to be a variable in the caller's namespace
# that is tested if its content equals its name. Throws an error if this doesn't hold.
# Example:
# proc Select {cols FROM table WHERE cond} {
# 	keyword_check FROM WHERE
# }
# Select * FORM MyTable WHERE X=5   --> error
# Select * From MyTable Where X=5   --> okay
proc keyword_check {args} {
	foreach keyword $args {
		upvar $keyword value

		if {! [string equal -nocase $value $keyword]} {
			catch {set command [lindex [info level -1] 0]}
			if {[info exists command]} {
				error "bad/missing keyword at \"$value\": should be \"$command [info args $command]\""
			} else {
				error "bad/missing keyword at \"$value\": should be \"$keyword\""
			}
		}

	}
}
