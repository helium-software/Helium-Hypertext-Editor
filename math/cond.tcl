# Condition evaluator for use inside of expr.
# Usage:
# cond(cond1,value1,cond2,value2,...)  [even #args]
#        If cond1 is true, returns value1; etc.
#        The value associated to the earliest matching condition is taken.
#        If no condition is true, an error is raised.
# cond(cond1,value1,...,defaultvalue)  [odd #args]
#        Same as above, but if no condition is true, defaultvalue is returned.
# When speed is more important than readability, use the built-in "cond ? value1 : value2"
# as in:
#   expr {
#        $x<1  ? 4  :
#        $x==1 ? 10 :
#        $x==2 ? 20 :
#                123
#   }
# The above example runs with 14.357 microseconds per iteration, while the same using cond()
# consumes 104.865 microseconds per iteration. [tested with time {expr {...}} 1000, x set to 2]
proc ::tcl::mathfunc::cond {args} {
	if {[llength $args]&1} {
		set args [linsert $args end-1 true]
	}
	foreach {condition value} $args {
		if {$condition} {return $value}
	}
	error "no condition matched"
}
