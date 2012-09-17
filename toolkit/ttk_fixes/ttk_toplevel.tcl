namespace eval ttk_fixes {}

set_ifnotexists ::ttk_fixes::toplevels [list .]

## As there is no themed toplevel window creator, we must use the following
## helper to create a toplevel that matches the style of its contained Ttk
## widget.
## This procedure creates the toplevel window as usual, and then applies
## some appearance properties (up to now: solely the background color),
## according to the current theme. If the theme is changed, the toplevel
## is reconfigured to match the new theme.
proc ttk_toplevel {windowpath args} {
	lappend ::ttk_fixes::toplevels $windowpath
	toplevel $windowpath {*}$args
	bindtag_add $windowpath ttk_toplevel
	# call theme-specific toplevel configurator
	::ttk_fixes::toplevel.[ttk_currentTheme] $windowpath
	return $windowpath
}
bind ttk_toplevel <Destroy> {lremoveitem ::ttk_fixes::toplevels %W}

## Theme-specific text configurators
# Clam
proc ::ttk_fixes::toplevel.clam {toplevel} {
	$toplevel configure -background #dcdad5
}
# Classic
proc ::ttk_fixes::toplevel.classic {toplevel} {
	$toplevel configure -background #d9d9d9
}
# Alt (near-Windows 95)
proc ::ttk_fixes::toplevel.alt {toplevel} {
	$toplevel configure -background #d9d9d9
}
# Default
proc ::ttk_fixes::toplevel.default {textwidget} {
	$toplevel configure -background #d9d9d9
}
