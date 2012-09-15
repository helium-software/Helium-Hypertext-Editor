proc ::tcl::mathfunc::cond {args} {
	if {[llength $args]%2==1} {
		set default_value [lindex $args end]
		set args [lrange $args 0 end-1]
	}
	foreach {condition value} $args {
		if {$condition} {return $value}
	}
	if {[info exists default_value]} {
		return $default_value
	} else {
		error "no condition matched"
	}
}

