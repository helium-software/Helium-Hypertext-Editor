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

#.t configure -selectbackground "#0ca" -inactiveselectbackground "#0ca"
.t tag configure yellow -background yellow
.t tag configure red -background red
tk_text::makeseltag .t yellow
tk_text::makeseltag .t red
.t tag add yellow 1.2 1.18
.t tag add yellow 3.2 4.14
.t tag add red 4.28 5.end
