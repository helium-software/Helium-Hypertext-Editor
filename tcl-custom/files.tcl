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
