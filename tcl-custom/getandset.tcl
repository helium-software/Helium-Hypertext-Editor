# define "get" as an alias for "set"
proc get {} {} ;# this is only for the tclIndex
interp alias "" get "" set

proc set_ifnotexists {variable value} {
	upvar $variable Variable
	if {![info exists Variable]} {set Variable $value}
	return $Variable
}
