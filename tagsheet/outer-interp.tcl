# To be sourced into ::tagsheet::outer-interp
# The 'iproc' command is a synonym to 'proc' that avoids those procs showing up in tclIndex.
iproc default {attribdefs} {
	# body
}
iproc linetype {name displayname attribdefs} {
	# body
	# inner-eval $attribdefs
}
iproc inlinetag {name displayname attribdefs} {
	# body
}
iproc listindents {num args} {
	# body
}

