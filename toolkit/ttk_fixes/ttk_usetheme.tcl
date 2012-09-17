namespace eval ::ttk_fixes {}

set ::ttk_fixes::currentTheme default

proc ttk_currentTheme {} {
	return $::ttk_fixes::currentTheme
}

set_ifnotexists ::ttk_fixes::texts [list]
set_ifnotexists ::ttk_fixes::toplevels [list .]

## "Wrapper" for 'ttk::style theme use' that triggers rearrangements in
## various parts of ttk_fixes on theme change, e.g. changing the padding
## widths of text widgets inside of ttk::frames.
proc ttk_useTheme {theme} {
	ttk::style theme use $theme
	set ::ttk_fixes::currentTheme $theme
	
	foreach text $::ttk_fixes::texts {
		::ttk_fixes::text.$theme $text
	}
	foreach toplevel $::ttk_fixes::toplevels {
		::ttk_fixes::toplevel.$theme $toplevel
	}
}

