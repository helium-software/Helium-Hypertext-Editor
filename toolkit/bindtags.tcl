## Utility procedures related to the bindtags mechanism

# Add additional bindtags (in $args) to those already defined for $window.
# The tags are appended just before ".", or at the end of the tag list.
proc bindtag_add {window args} {
	set tags [bindtags $window]
	set dotpos [lsearch $tags .]
	if {$dotpos==-1} {
		lappend tags {*}$args
	} else {
		set tags [linsert $tags $dotpos {*}$args]
	}
	bindtags $window $tags
}
