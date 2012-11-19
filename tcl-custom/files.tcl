proc readfile {filename} {
	set channel [open $filename]
	set content [read $channel]
	close $channel
	return $content
}
proc writefile {filename content} {
	set channel [open $filename w]
	puts -nonewline $channel $content
	close $channel
}
# reads $filename, discarding the trailing newline if present
proc readfile_discardnl {filename} {
	set content [readfile $filename]
	if {[string index $content end]=="\n"} {
		return [string range $content 0 end-1]
	}
	return $content
}
# writes $filename, adding a trailing newline if none present
proc writefile_addnl {filename content} {
	if {[string index $content end]!="\n"} {
		append content "\n"
	}
	writefile $filename $content
}
