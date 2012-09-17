proc lremove {listvar start end} {
	upvar $listvar Listvar
	set Listvar [lreplace $Listvar $start $end]
}
proc lremoveitem {listvar item} {
	upvar $listvar Listvar
	set pos [lsearch $Listvar $item]
	if {$pos==-1} {error "item $item not found"}
	set Listvar [lreplace $Listvar $pos $pos]
}
