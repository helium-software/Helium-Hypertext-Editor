Tagsheets
=========

[(Zur deutschen Version)](README-de.md)

The Native Data Format is designed to allow the _use_ of arbitrary paragraph and character styles, specified through their names, e.g. `bold`. (Usage of undefined styles leads to verbatim output of the corresponding markup, because the parser is designed to always succeed.) The _definition_ of those styles is performed in another file, called the **tagsheet**. It lists the available styles, along with instructions on their presentation in the text widget (WYSIWYM mode). A website project typically has a single central tagsheet. The interpretation of the tags during translation into other formats (HTML, TeX etc.) is _not_ part of the tagsheets; it is specified in **template files**, one for each format.

Synopsis
--------

* [Example](#example)
* [Structure](#structure)
   * [inlinetag](#inlinetag)
   * [linetype](#linetype)
   * [default](#default)
   * [listindents](#listindents)
   * [padding](#padding)
   * [selection](#selection)
   * [cursor](#cursor)
   * [reset](#reset)
* [Attribute Definitions](#attribute-definitions)
   * [References](#references)
   * [Literal Values; Operators](#literal-values-operators)

Example
-------

```
default {
	font = "DejaVu Sans"
	size = 12
}
linetype h1 "Heading 1" {
	size = 20
	bold = true
	topskip = 5 ; bottomskip = 3
}
inlinetag emph "Emphasize" {
	italic = not parent.italic
	italic toggle  ;#alternative form
}
inlinetag big "Bigger" {
	size = parent.size + 4
	size += 4      ;#alternative form
}
inlinetag bold "Bold print" {
	bold = true
}
```

Structure
---------

A tagsheet is a Tcl script that makes use of some specific commands (while being prohibited from using some other, dangerous ones). It consists of a sequence of style definitions (commands _linetype_, _default_, or _inlinetag_) and special statements (<i>listindent</i> etc.), and — in complex cases — standard Tcl commands like _set_ or _lindex_.

### inlinetag

Syntax: `inlinetag <name> <displayed name> { attribute definitions }`

Defines a character style named _\<name\>_ (in source code) resp. _\<displayed name\>_ (in the WYSIWYM interface) and sets up its presentation attributes. Allowed attributes are:

| Attribute      | Signification
| -------------- | -------------
| **font**       | Font family to be used, e.g. `font = DejaVu Sans`
| **size**       | Font size in px
| **bold**       | Turns bold type on/off. Possible values: `yes`=`on`=`true`=`1`, `no`=`off`=`false`=`0` (similar for all following "on/off" attributes).
| **italic**     | Turns italic script on/off.
| **underline**  | Turns underlining on/off.
| **overstrike** | Turns overstriking on/off.
| **offset**     | Vertical offset of the text from the baseline, useful for superscript and subscript. Specified in px, positive values shift text to the top.
| **color**      | Color of the letters (foreground). Allowed are named colors (like `violet`) and colors in hex notation (like `#ca04de` or `#c0d`).
| **background** | Color of the text background. Note that when the cursor enters a tagged span of text, that span will be highlighted, such that this attribute temporarily has no effect. Same is true for text selection.

### linetype

Syntax: `linetype <name> <displayed name> { attribute definitions }`

Defines a paragraph style named _\<name\>_ (in source code) resp. _\<displayed name\>_ (in the WYSIWYM interface) and sets up its presentation attributes. In addition to those mentioned at _inlinetag_, the following attributes are allowed:

| Attribute          | Signification
| ------------------ | -------------
| **leftmargin**     | Left margin in px. If the element is indented (indent level > 0), the specification is relative to the indenting, otherwise to the left border of the text widget. Negative values are allowed. <br>Setting _leftmargin_ **automatically overwrites** _leftmargin1_ with the same value.
| **leftmargin1**    | Left margin of the first line, must be specified **after _leftmargin_**. The value is likewise relative to the indenting resp. the widget border. Using _leftmargin_ as a reference is possible, e.g. `leftmargin1 = leftmargin + 12`.
| **rightmargin**    | Right margin (in px), applies to all lines of the paragraph.
| **topskip**        | Vertical distance from the previous paragraph (in px)
| **bottomskip**     | Vertical distance to the next paragraph (in px). _topskip_ and _bottomskip_ of subsequent paragraphs do not merge.
| **lineskip**       | Vertical space between lines of the same paragraph. The specified value (in px) is added to the line spacing provided by the font.
| **align**          | Horizontal alignment of the paragraph, possible are `left`, `center`, and `right`. Justification is not available because the Tk text widget does not support it.
| **bullet**         | Bullet character, e.g. `bullet = ‣`, or `bullet = ""` (do not place a bullet character). <br>For numbered lists, include a "one" in the appropriate format, i.e.: <br>"1" for numeric; "A"/"a" for upper/lower alphabetic; "I"/"i" for upper/lower roman; "α" for lower greek. Example: `bullet = "a)"`
| **bulletdistance** | Space between bullet character and text (first line). Even if a bullet character is present, the attributes _leftmargin_ and _leftmargin1_ refer to the text. The bullet character is placed _bulletdistance_ px left to the start of the text. Choose a distance of at least 7 px, otherwise the Tk text widget will damage the text alignment, because it imposes a minimum width of tab characters.
| **bulletcolor** | Color of the bullet character (foreground)

### default

Syntax: `default { attribute definitions }`

Defines the style used for plain paragraphs. Additionally, the attributes defined here form a basis for all the paragraph styles, i.e if a paragraph style does not set an attribute, it is inherited from the default style. The set of available attributes is the same as for _linetype_.

### listindents

Syntax: `listindents +<num> ?+<num> ...? ?...?`

Defines the indentation margins for all types of lists. An arbitrary number of _+\<num\>_ arguments is allowed. Each argument specifies the distance (in pixels), by which an entry of the related indent level is placed **further to the right** than one of the previous level. (The plus signs emphasize the values being relative ones.) If the text contains entries with an indent level that doesn't correspond to an argument, the last argument is implicitly repeated. (The optional three dots are intended to reflect this behavior to an uninformed reader.)

Example: `listindents  +10 +10 +10 +4 ...` defines an indentation step of 10 px for the first three levels, and 4 px for the rest. This results in the following absolute indentation margins:

| Indent level     |   0   |   1    |   2    |   3    |    4   |    5   |    6   |    7   | ...
| ---------------- | ----- | ------ | ------ | ------ | ------ | ------ | ------ | ------ | -------
| **Left margin**  | **0** | **10** | **20** | **30** | **34** | **38** | **42** | **46** | **...**

### padding

Syntax: `padding { attribute definitions }`

Defines the distances by which all text content should be placed apart from the text widget's borders. In difference to the effects available with the _leftmargin_, _rightmargin_, _topskip_ and _bottomskip_ attributes, the "padding" area can be thought as a **picture frame** that (1) lies above the text and hides overflow lines if the text contents are larger than the widget, and (2) its color is not affected by any text markup tags that set background colors. Internally the `-padx -pady` properties of the Tk text widget are set to those values.

The _{ attribute definitions }_ are similar to those in other commands, but **only the attributes _x_ and _y_ are available**; they set the sizes of the left/right resp. top/bottom border. References of types _default.\<attr\>_ and _\<linetype\>.\<attr\>_ are accepted. It is also possible to refer to the values of _x_ and _y_, as in `x = 4; y = x-3`.

### selection

Syntax: `selection { attribute definitions }`

Defines the appearance of selected text. The following attributes are provided:

| Attribute | Signification
| --------- | -------------
| **color** | The color used for highlighting selected text.
| **alpha** | Opacity/transparency of the coloured highlight mark, greater values mean more opacity. Allowed range is 0 to 1.

References of types _default.\<attr\>_ and _\<linetype\>.\<attr\>_ are accepted.

### cursor

Syntax: `cursor { attribute definitions }`

Defines the appearance of the blinking insertion cursor. The following attributes are provided:

| Attribute   | Signification
| ---------   | -------------
| **color**   | cursor color (standard: black)
| **width**   | cursor width in px. _When the cursor is placed at the left border of the widget, half of it gets unfortunately cut off, even with larger "padding" borders. This Tk misbehaviour can be masked by setting a width of 1._
| **ontime**  | Duration of the blink phase where the cursor is visible (unit: milliseconds).
| **offtime** | Duration of the blink phase where the cursor is invisible (unit: milliseconds). _Setting zero completely disables blinking, which can be favorable for slow X11 connections._

References of types _default.\<attr\>_ and _\<linetype\>.\<attr\>_ are accepted, as well as referring to previously set attributes, as in `ontime = 500; offtime = ontime - 200`.

### reset

Syntax: `reset`

This "parasitic" (not originally intended to be part of the tagsheet language) command discards any settings that have been done above it. It could become useful for tagsheet debugging, as it allows for single-feature tests at the bottom of a file without deleting (i.e. moving into editing history) its normal contents. In other situations, using `if 0 { }` may be more suitable.


Attribute Definitions
---------------------

This section describes the syntax of the _{ attribute definitions }_ field that has been mentioned in the previous sections.<br>
_For a short overview, see the [German version](README-de.md#attribut-definitionen)._

Between the curly braces (see the [Example](#example)), an arbitrary number of attribute definitions can be specified, either each on an individual line, or multiple definitions on one line, separated by semicolons.

(Internally, the _{ attribute definitions }_ field is a "Tcl script" argument that is executed inside the commands like _linetype_ etc. It is exactly the same as e.g. the body of an _if_ condition, except that the attribute definitions are available as custom Tcl commands inside this field.)

Each attribute definition can be one of the following types:

* `<attribute> = <value>`<br>
  Sets an attribute to the given literal value (see section [Literal Values & Operators](#literal-values-operators)). _\<value\>_ may also be an **expression** composed of literal values, operators (see [section](#literal-values-operators)) and other attribute names (see section [References](#references)).

* `<attribute> += <value>`<br>
  `<attribute> -= <value>`<br>
  `<attribute> *= <value>`<br>
  `<attribute> /= <value>`<br>
  Shorthand notation for `<attribute> = <reference> + <value>`, `<attribute> = <reference> - <value>` etc.<br>
  In a _linetype_ section, _\<reference\>_ means `default.<attribute>`.<br>
  In an _inlinetag_ section, _\<reference\>_ means `parent.<attribute>`.<br>
  In all other types of sections, this statement is illegal, since there is nothing to refer to.

* `<attribute> toggle`<br>
  Sets a "yes/no"-type attribute to the opposite value. Only allowed in _inlinetag_ definitions where it is equivalent to `<attribute> = not parent.<attribute>` and `<attribute> = parent.<attribute> xor 1`.

* `<assigment> if <condition>`<br>
   The _\<assignment\>_, which may take any of the forms described above, is only issued if the _\<condition\>_ is true. The condition is an expression that contains a **comparison operator**: `= ==` (equals), `!= <> ≠` (not equal to), `>` (greater than), `>= ≥` (greater or equal), `<` (less than), `<= ≤` (less or equal).

### References

| Syntax | Refers to | Allowed in |
| ------ | --------- | ---------- |
| `default.<attr>` | Value of _\<attr\>_ defined in `default` section | inlinetag, linetype |
| `parent.<attr>` | Value of _\<attr\>_ just outside the current tag range | inlinetag |
| `<linetype>.<attr>` | Value of _\<attr\>_ as set in the definition of _\<linetype\>_ | inlinetag, linetype |
| `<attr>` | Value of _\<attr\>_ as defined before | default |

All references except _parent.\<attr\>_ are evaluated in a single pass, while the tagsheet is being read into the interpreter. This means that each reference will access the corresponding attribute value as it has been set by all the preceding attribute definitions.  Circular references like `a=b; b=a` are therefore impossible, since the first statement tries to access `b` which is unknown at this time (or it sets `a` to the default value for `b` if that exists). This is typical **imperative semantics; Tagsheets are not purely declarative.**

### Literal Values; Operators

| Type                        | Literal values       | Operators |
| --------------------------- | -------------------- | --------- |
| **Numbers**                 | like `123` or `1.54` | Standard operators `+ - * /` are defined. Unicode `·` is allowed for multiplication. |
| **Flags** ("yes/no" values) | `yes no on off true false` | Boolean operators `and or not xor` |
| **Strings** (text values)   | `Singleword` `"multi word"` `{$trange"chars}` | A space between two string values joins them with a space between. |

The "space operator" for strings has been designed to effectively allow writing multi-word values without any quotes, as in `font = Century Schoolbook L`. Additionally, the following code example is valid, resulting _bbb_ having a _font_ attribute of "DejaVu Sans Condensed":
```
linetype aaa AAA {
	font = DejaVu Sans
}
linetype bbb BBB {
	font = aaa.font Condensed
}
```
