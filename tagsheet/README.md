Tagsheets
=========

[(springe zur deutschen Version)](#tagsheets-deutsch)

The Native Data Format is designed to allow the _use_ of arbitrary paragraph and character styles, specified through their names, e.g. `bold`. (Usage of undefined styles leads to verbatim output of the corresponding markup, because the parser is designed to always succeed.) The _definition_ of those styles is performed in another file, called the **tagsheet**. It lists the available styles, along with instructions on their presentation in the text widget (WYSIWYM mode). A website project typically has a single central tagsheet. The interpretation of the tags during translation into other formats (HTML, TeX etc.) is _not_ part of the tagsheets; it is specified in **template files**, one for each format.

Synopsis
--------

* [Example](#example)
* [Structure](#structure)
   * [inlinetag](#inlinetag)
   * [linetype](#linetype)
   * [default](#default)
   * [listindents](#listindents)
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
	italic = parent.italic xor 1
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

A tagsheet is a Tcl script that makes use of some specific commands (while being prohibited from using some other, dangerous ones). It consists of a sequence of style definitions (commands _linetype_, _default, or _inlinetag_) and special statements (_listindent_ etc.), and — in complex cases — standard Tcl commands like _set_ or _lindex_.

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
| **leftmargin**     | Left margin in px. If the element is indented (indent level > 0), the specification is relative to the indenting, otherwise to the left border of the text widget. Negative values are allowed.
| **leftmargin1**    | Left margin of the first line. If unspecified, _leftmargin_ is used. The value is likewise relative to the indenting resp. the widget border. Using _leftmargin_ as a reference is possible, e.g. `leftmargin1 = leftmargin + 12`.
| **rightmargin**    | Right margin (in px), applies to all lines of the paragraph.
| **topskip**        | Vertical distance from the previous paragraph (in px)
| **bottomskip**     | Vertical distance to the next paragraph (in px). _topskip_ and _bottomskip_ of subsequent paragraphs do not merge.
| **lineskip**       | Vertical space between lines of the same paragraph. The specified value (in px) is added to the line spacing provided by the font.
| **align**          | Horizontal alignment of the paragraph, possible are `left`, `center`, and `right`. Justification is not available because the Tk text widget does not support it.
| **bullet**         | Bullet character, e.g. `bullet = ‣`, or `bullet = ""` (do not place a bullet character)
| **bulletdistance** | Space between bullet character and text (first line). Even if a bullet character is present, the attributes _leftmargin_ and _leftmargin1_ refer to the text. The bullet character is placed _bulletdistance_ px left to the start of the text.

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


Attribute Definitions
---------------------

This section describes the syntax of the _{ attribute definitions }_ field that has been mentioned in the previous sections.<br>
_For a short overview, see the [German version](attribut-definitionen) below._

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
  Sets a "yes/no"-type attribute to the opposite value. Only allowed in _inlinetag_ definitions where it is equivalent to `<attribute> = parent.<attribute> xor 1`.

* `<assigment> if <condition>`<br>
   The _\<assignment\>_, which may take any of the forms described above, is only issued if the _\<condition\>_ is true. The condition is an expression that contains a **comparison operator**: `= ==` (equals), `!= <> ≠` (not equal to), `>` (greater than), `>= ≥` (greater or equal), `<` (less than), `<= ≤` (less or equal).

### References

| Syntax | Refers to | Allowed in |
| ------ | --------- | ---------- |
| `default.<attr>` | Value of _\<attr\>_ defined in `default` section | inlinetag, linetype |
| `parent.<attr>` | Value of _\<attr\>_ just outside the current tag range | inlinetag |
| `<linetype>.<attr>` | Value of _\<attr\>_ as set in the definition of _\<linetype\>_ | inlinetag, linetype |
| `<attr>` | Value of _\<attr\>_ as defined before | default |

All references except _default.\<attr\>_ are evaluated in a single pass, while the tagsheet is being read into the interpreter. This means that each reference will access the corresponding attribute value as it has been set by all the preceding attribute definitions.  Circular references like `a=b; b=a` are therefore impossible, since the first statement tries to access `b` which is unknown at this time (or it sets `a` to the default value for `b` if that exists). This is typical **imperative semantics; Tagsheets are not purely declarative.**

### Literal Values; Operators

| Type                        | Literal values       | Operators |
| --------------------------- | -------------------- | --------- |
| **Numbers**                 | like `123` or `1.54` | Standard operators `+ - * /` are defined. Unicode `·` is allowed for multiplication. |
| **Flags** ("yes/no" values) | `yes no on off true false` | Boolean operators `and or not xor` |
| **Strings** (text values)   | `Singleword` `"multi word"` `{$trange"chars}` | No operators available. |

-----------------------------------------------------------------------------

Tagsheets (deutsch)
===================

Das Native Datenformat sieht die _Verwendung_ beliebiger Absatz- und Zeichenstile vor, die durch ihren Namen (z.B. `bold`) spezifiziert werden. (Nicht definierte Stile führen zu einer Ausgabe des betreffenden Markup als Reintext, da der Parser nie einen Fehler zurückgeben soll.) Die _Definition_ der Absatz- und Zeichenstile übernimmt eine weitere Datei, das sogenannte **Tagsheet**. Darin werden die vorhandenen Stile aufgezählt, zusammen mit Anweisungen zu deren Darstellung im Textwidget (WYSIWYM-Modus). Typischerweise hat ein Webseiten-Projekt genau ein zentrales Tagsheet. Die Funktion der Tags bei der Ausgabe in andere Formate (HTML, TeX etc.) ist _nicht_ Bestandteil des Tagsheets, sondern wird für jedes Format in einer **Template-Datei** vermerkt.

Übersicht
---------

* [Beispiel](#beispiel)
* [Aufbau](#aufbau)
   * [inlinetag](#inlinetag-1)
   * [linetype](#linetype-1)
   * [default](#default-1)
   * [listindents](#listindents-1)
* [Attribut-Definitonen](#attribut-definitionen)


Beispiel
--------

```
default {
	font = "DejaVu Sans"
	size = 12
}
linetype h1 "Überschrift 1" {
	size = 20
	bold = true
	topskip = 5 ; bottomskip = 3
}
inlinetag emph "Betont" {
	italic = parent.italic xor 1
	italic toggle  ;#alternative Form
}
inlinetag big "Größer" {
	size = parent.size + 4
	size += 4      ;#alternative Form
}
inlinetag bold "Fettdruck" {
	bold = true
}
```

Aufbau
------

Ein Tagsheet ist ein Tcl-Skript, dem spezielle Befehle zur Verfügung stehen (und gewisse gefährliche Befehle nicht). Es besteht aus einer Folge von Stil-Definitionen (Befehl _linetype_ oder _inlinetag_) und Spezial-Statements (_listindent_ etc.); für komplexe Fälle stehen auch Standard-Tcl-Befehle wie _set_ oder _lindex_ zur Verfügung.

### inlinetag

Syntax: `inlinetag <Name> <Angezeigter Name> { Attribut-Definitionen }`

Definiert einen Zeichen-Stil _\<Name\>_ (im Quelltext) resp. _\<Angezeigter Name\>_ (im WYSIWYM-Editor) und setzt dessen Darstellungsattribute. Erlaubte Attribute sind:

| Attribut       | Bedeutung
| -------------- | ---------
| **font**       | Angabe der Schriftfamilie, Bsp: `font = DejaVu Sans`
| **size**       | Angabe der Schriftgröße in px
| **bold**       | Schaltet Fettdruck ein/aus. Erlaubte Werte: `yes`=`on`=`true`=`1`, `no`=`off`=`false`=`0` (auch für alle folgenden "ein/aus"-Attribute).
| **italic**     | Schaltet Kursivschrift ein/aus.
| **underline**  | Schaltet Unterstreichen ein/aus.
| **overstrike** | Schaltet Durchstreichen ein/aus.
| **offset**     | Vertikale Verschiebung des Textes von der Grundlinie, nützlich für Hoch- und Tiefstellung. Angegeben in px, positive Werte verschieben Text nach oben.
| **color**      | Farbe der Buchstaben (Vordergrund). Erlaubt sind benannte Farbangaben (wie `violet`) und Farbangaben in Hex-Notation (wie `#ca04de` oder `#c0d`).
| **background** | Farbe des Hintergrunds. Beim Betreten eines ausgezeichneten Elements mit dem Cursor wird es hellblau/hellgelb/hellorange hervorgehoben, so dass dieses Attribut zeitweise keine Wirkung hat, ebenso bei der Auswahl von Text.


### linetype

Syntax: `linetype <Name> <Angezeigter Name> { Attribut-Defintionen }`

Definiert einen Absatz-Stil _\<Name\>_ (im Quelltext) resp. _\<Angezeigter Name\>_ (im WYSIWYM-Editor) und setzt dessen Darstellungsattribute. Zusätzlich zu den bei _inlinetag_ erwähnten Attributen sind folgende erlaubt:

| Attribut           | Bedeutung
| ------------------ | ---------
| **leftmargin**     | Linker Rand, Angabe in px. Falls das Element eingerückt ist (Einrückungsstufe > 0), ist die Angabe relativ zu (Einrückungsstufe * Einrückung), sonst zum linken Fensterrand. Negative Werte sind möglich.
| **leftmargin1**    | Einzug der ersten Zeile. Falls nicht angegeben, wird _leftmargin_ übernommen. Die Angabe bezieht sich ebenfalls auf den Einrückungsabstand bzw. den linken Fensterrand. Bezug auf _leftmargin_ ist möglich durch z.B. `leftmargin1 = leftmargin + 12`.
| **rightmargin**    | Rechter Rand (in px), gültig für alle Zeilen des Absatzes.
| **topskip**        | Abstand vom vorhergehenden Absatz (in px)
| **bottomskip**     | Abstand zum nachfolgenden Absatz (in px). _topskip_ und _bottomskip_ aufeinanderfolgender Absätze verschmelzen nicht.
| **lineskip**       | Abstand zwischen Zeilen innerhalb des Absatzes. Die Angabe (in px) wird zum vom Font vorgegebenen Zeilenabstand addiert.
| **align**          | Ausrichtung, `left`=linksbündig, `center`=zentriert, `right`=rechtsbündig. Blocksatz ist nicht möglich, da das Tk-Textwidgets diesen nicht unterstützt.
| **bullet**         | Aufzählungszeichen, Bsp. `bullet = ‣` oder `bullet = ""` (kein Aufzählungszeichen setzen)
| **bulletdistance** | Abstand des Aufzählungszeichens vom Text (erste Zeile). Wenn ein Aufzählungszeichen vorhanden ist, gelten die Angaben _leftmargin_ und _leftmargin1_ weiterhin für den Abstand des Textes. Das Aufzählungszeichen wird um _bulletdistance_ px links vom Textbeginn ausgegeben.

### default

Syntax: `default { Attribut-Definitionen }`

Definiert den Stil, den unformatierte Absätze haben. Zusätzlich werden die hier definierten Attribute als Basis für alle Absatzstile genutzt, d.h. wenn ein Absatzstil eine Eigenschaft nicht definiert, wird sie vom Default-Stil übernommen. Die verfügbaren Attribute sind dieselben wie bei _linetype_.

### listindents

Syntax: `listindents +<num> ?+<num> ...? ?...?`

Definiert die Einrückungsabstände für Aufzählungslisten. Es dürfen beliebig viele Angaben _+\<num\>_ gemacht werden. Jede Angabe spezifiziert eine Distanz in Pixel, um die Einträge der betreffenden Einrückungsstufe **weiter nach rechts** bezüglich zur vorigen Stufe gesetzt werden sollen. (Die Pluszeichen betonen, dass es sich um relative Angaben handelt.) Falls im Text eine Einrückungsstufe vorkommt, zu der kein Wert gegeben mehr angegeben wurde, wird die letzte Angabe vervielfältigt. (Die freiwilligen drei Punkte sollen dieses Verhalten einem nicht informierten Leser dokumentieren.)

Beispiel: `listindents  +10 +10 +10 +4 ...` definiert eine Einrückung von 10 px für die ersten drei Stufen und 4 px für alle weiteren. Es ergeben sich die folgenden absoluten Einrückungsabstände:

| Einrückungstiefe |   0   |   1    |   2    |   3    |    4   |    5   |    6   |    7   | ...
| ---------------- | ----- | ------ | ------ | ------ | ------ | ------ | ------ | ------ | -------
| **Abstand**      | **0** | **10** | **20** | **30** | **34** | **38** | **42** | **46** | **...**


Attribut-Definitionen
---------------------

_Dies ist eine kurze Übersicht. Für Details siehe die [englische Version](attribute-definitions)._

* In default:
    * Keine Referenzen, ausser auf vorher definierte andere Attribute (z.B. `italic = yes; bold = italic`)
* In linetype:
    * Default-Referenz für += etc. und toggle ist der Default-Stil.
    * Referenz auf Default-Stil: `aaa = default.bbb`
    * Referenz auf andere Stile: `aaa = myheading.bbb`
* In inlinetag:
    * Default-Referenz für += etc. und toggle ist der Stil des Vorgängers (beinhaltender inlinetag / linetype / default).
    * Referenz auf Vorgänger: `aaa = parent.bbb`
    * Keine Referenz auf andere inlinetags erlaubt, da diese Vorgänger-relativ sind.
    * Referenz auf linetype: `aaa = myheading.bbb`
    * Referenz auf Default-Stil: `aaa = default.bbb`
* Allgemein darf nicht auf weiter unten definierte Stile (bzw. Attribute im selben Stil-Block) Bezug genommen werden (sonst könnten Zirkelschlüsse wie `aaa = bbb; bbb = aaa` entstehen). Es ist jedoch -- wie in CSS -- erlaubt, einen Stil nachträglich mit einem Attributblock zu erweitern. Damit sollten verschiedene Design-Aspekte (Bsp. Positionierung und Farbgebung) besser auseinander gehalten werden können.

```
linetype test {
	aaa = 12
}
linetype other {
	bbb = test.aaa
}
linetype test {
	bbb = aaa
}
```
