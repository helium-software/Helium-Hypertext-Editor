# To be sourced into ::tagsheet::outer-interp
# The 'iproc' command is a synonym to 'proc' that avoids those procs showing up in tclIndex.

## Global variables:
#   ::context        tells attr_set from what kind of definition it is called
#   ::name           tells attr_set to which name the current definitions belong
#   ::dotattributes  dict with mapping linetype.attr -> value
#                     used to resolve "linetype.attr" references in attr_set [using string map]
#
#   ::default_attrs  dict with mapping attr -> value, contains definitions made in
#                     "default" statement(s)
#   ::linetypes      dict with mapping name -> [dict with mapping attr -> value], 
#                     contains definitions made in "linetype" statements
#   ::inlinetags     dict with mapping name -> [dict with mapping attr -> value_expr],
#                     contains definitions made in "inlinetag" statements
#
#   ::linetype_displaynames   dict with mapping name -> displayname, for linetype styles only
#   ::inlinetag_displaynames  dict with mapping name -> displayname, for inlinetag styles only
#
#   ::parent_refs    dict with mapping "parent.name" -> "$name" for inlinetags
foreach inline_attr {font color background size offset bold italic underline overstrike} {
	dict set ::parent_refs parent.$inline_attr $$inline_attr
}

iproc reset {} {
	set ::dotattributes [dict create]
	set ::default_attrs [dict create \
		font "Sans"  color black  background white  size 13     \
		bold 0  italic 0  offset 0  underline 0  overstrike 0   \
		leftmargin 0  leftmargin1 0  rightmargin 0  align left  \
		topskip 0  bottomskip 0  lineskip 0                     \
		bulletdistance 0  bullet ""                             ]
	set ::linetypes [dict create]
	set ::inlinetags [dict create]
	set ::linetype_displaynames [dict create]
	set ::inlinetag_displaynames [dict create]
}

## Implementation of tagsheet user commands

iproc default {attribdefs} {
	set ::context default
	set ::name    default

	inner-eval {set ::MODE default}
	inner-eval [attribdef_subst $attribdefs]
}
iproc linetype {name displayname attribdefs} {
	set ::context linetype
	set ::name $name
	dict set ::linetype_displaynames $name $displayname
	if {![dict exists $::linetypes $name]} {dict set ::linetypes $name [dict create]}

	inner-eval {set ::MODE linetype}
	inner-eval [attribdef_subst $attribdefs]
}
iproc inlinetag {name displayname attribdefs} {
	set ::context inlinetag
	set ::name $name
	dict set ::inlinetag_displaynames $name $displayname
	if {![dict exists $::inlinetags $name]} {dict set ::inlinetags $name [dict create]}

	inner-eval {set ::MODE inlinetag}
	inner-eval [attribdef_subst $attribdefs]
}
iproc listindents {num args} {
	# body: TODO
}

## Helper for tagsheet user commands

iproc attribdef_subst {attribdefs} {
	set attribdefs [uplevel #0 [list subst $attribdefs]]
	# make sure that attribdefs now do not contain any $var and [cmd] (search for $ [ ] )
	if {[string match {*[\[\]$]*} $attribdefs]} {
		error "attribute definition still contains \$ \[ \] after substitution"
	}
	return $attribdefs
}

## Logic for setting attributes

iproc attr_set {attr expr} {
	## check if attr is valid in this context
	set type [attr_gettype $attr]
	## substitute "linetype.attr" and "attr" references with actual (numeric/literal) values
	switch $::context {
	"default" {
		# substitute "attr"
		set expr [string map $::default_attrs $expr]
	} "linetype" {
		# substitute "linetype.attr"
		set expr [string map $::dotattributes $expr]
		# substitute "attr" (references into the linetype just being defined)
		set expr [string map [dict get $::linetypes $::name] $expr]
	} "inlinetag" {
		# substitute "linetype.attr"
		set expr [string map $::dotattributes $expr]
		# substitute "parent.attr" and "attr"  (in the same step, since
		#  "parent.attr" is replaced with something that still contains "attr")
		set expr [string map [dict merge $::parent_refs [dict get $::inlinetags $::name]] $expr]
	}}
	## calculate the resulting attribute, depending on its type
	switch $type {
	String {
		# don't do anything
	} Number {
		# if we can (no parent references), calculate $expr as an expression, 
		if {[string first {$} $expr] == -1} {
			set expr [expr $expr]
		# otherwise run a test against sample default values:
		} else {
			set size 12; set offset 0
			if {[catch {expr $expr}]} {error "invalid expression syntax"}
		}
	} Flag {
		# translate logical constants and operators to "C" style
		# (expr does not provide calculations with yes and friends)
		set expr [string map {" xor " ^ " and " & " or " | "not " !
			yes 1 no 0 on 1 off 0 true 1 false 0} $expr]
		# if we can (no parent references), calculate $expr as an expression,
		if {[string first {$} $expr] == -1} {
			set expr [expr $expr]
		# otherwise run a test against sample default values:
		} else {
			set bold 0; set italic 0; set underline 0; set overstrike 0
			if {[catch {expr $expr}]} {error "invalid expression syntax"}
		}
	}}
	## store the resulting attribute ($expr) in the appropriate place
	switch $::context {
	"default" {
		dict set ::default_attrs $attr $expr
		dict set ::dotattributes default.$attr $expr
	} "linetype" {
		dict set ::linetypes $::name $attr $expr
		dict set ::dotattributes $::name.$attr $expr
	} "inlinetag" {
		dict set ::inlinetags $::name $attr $expr
	}}
	puts "attr_set $attr ←← $expr"
}
# the following two procedures are identical to those in inner-interp.tcl (with attr_ prefix)
iproc isattr {attr} {
	return [expr {$attr in [list font color background size offset bold italic underline \
		overstrike leftmargin leftmargin1 rightmargin topskip bottomskip lineskip \
		bulletdistance align bullet]}]
}
iproc isinlineattr {attr} {
	return [expr {$attr in [list font color background size offset bold italic underline \
		overstrike]}]
}
