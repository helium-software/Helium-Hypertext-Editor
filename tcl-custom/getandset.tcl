proc get {arg} {uplevel [list set $arg]}
proc set_ifnotexists {variable value} {
	upvar $variable Variable
	if {![info exists Variable]} {set Variable $value}
	return $Variable
}
