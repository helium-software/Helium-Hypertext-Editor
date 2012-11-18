#!/usr/bin/wish8.5

## Make tclIndex accessible

# Relative path to tclIndex - needs to be updated (add/remove some ..)
#  whenever this script is moved into a different hierarchy level
set dir [file join [file dirname [info script]] .. ..]
source [file join $dir tclIndex]

# ====================================================================
# Actual Test Code begins

pack [text .t -font "Monospace -16"]
bindtag_add .t TextSelMechanism

.t insert end {Hello lanel anfianf iafn afn awf
Lorem Ipsum ajlka lkdfjlakfjkl afjalkdfja
awkj af jldf jwkf jdf lf afl akfl jwklf awl kajflk  flkjf lkfj 
jklaef kladjf kljf kldja lkejf akljf kdefj ews dbvrhkb udirezewiu wef
efwk hwefwtg ivxubxcuosdb vbuiaf wboscib wib weobuobuo}

.t configure -selectbackground "#0ca" -inactiveselectbackground "#0ca"
tk_text::setalpha .t 0.75 ;# important here for auto_loading the tk_text namespace
.t tag configure yellow -background yellow
.t tag configure red -background red
.t tag add yellow 1.2 1.18
.t tag add yellow 3.2 4.14
.t tag add red 4.28 5.end
.t tag configure white -background white
.t insert end "   " "" "white background" white "\n"
