namespace eval ::colorcalc {
	namespace import ::tcl::mathfunc::int
}

# Helper image for reading color strings (like "yellow" or "#fcd") into R/G/B values
image create photo ::colorcalc::testphoto -width 1 -height 1

# converts a color string (like "green" or "#00ccde") into a list {r g b}
proc ::colorcalc::fromstring {color} {
	testphoto put $color
	testphoto get 0 0
}

# converts a color in list notation back to a string (like "#abcdef")
proc ::colorcalc::tostring {color} {
	foreach i {0 1 2} {lset color $i [int [lindex $color $i]]}
	format "#%02x%02x%02x" {*}$color
}

# calculates "alpha*foreground + (1-alpha)*background"
proc ::colorcalc::alphablend {foreground background alpha} {
	foreach i {0 1 2} {
		lappend result [expr {
			$alpha*[lindex $foreground $i]
			+ (1-$alpha)*[lindex $background $i]
		}]
	}
	return $result
}
# same as above, works directly on color strings
proc ::colorcalc::alphablendstrings {foreground background alpha} {
	tostring [alphablend [fromstring $foreground] [fromstring $background] $alpha]
}
