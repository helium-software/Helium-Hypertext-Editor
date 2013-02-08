Tagsheets (deutsch)
===================

[(Go to English version)](README.md)

Das Native Datenformat sieht die _Verwendung_ beliebiger Absatz- und Zeichenstile vor, die durch ihren Namen (z.B. `bold`) spezifiziert werden. (Nicht definierte Stile führen zu einer Ausgabe des betreffenden Markup als Reintext, da der Parser nie einen Fehler zurückgeben soll.) Die _Definition_ der Absatz- und Zeichenstile übernimmt eine weitere Datei, das sogenannte **Tagsheet**. Darin werden die vorhandenen Stile aufgezählt, zusammen mit Anweisungen zu deren Darstellung im Textwidget (WYSIWYM-Modus). Typischerweise hat ein Webseiten-Projekt genau ein zentrales Tagsheet. Die Funktion der Tags bei der Ausgabe in andere Formate (HTML, TeX etc.) ist _nicht_ Bestandteil des Tagsheets, sondern wird für jedes Format in einer **Template-Datei** vermerkt.

Übersicht
---------

* [Beispiel](#beispiel)
* [Aufbau](#aufbau)
   * [inlinetag](#inlinetag)
   * [linetype](#linetype)
   * [default](#default)
   * [listindents](#listindents)
   * [padding](#padding)
   * [selection](#selection)
   * [cursor](#cursor)
   * [reset](#reset)
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
	italic = not parent.italic
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

Ein Tagsheet ist ein Tcl-Skript, dem spezielle Befehle zur Verfügung stehen (und gewisse gefährliche Befehle nicht). Es besteht aus einer Folge von Stil-Definitionen (Befehl _linetype_ oder _inlinetag_) und Spezial-Statements (<i>listindent</i> etc.); für komplexe Fälle stehen auch Standard-Tcl-Befehle wie _set_ oder _lindex_ zur Verfügung.

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
| **leftmargin**     | Linker Rand, Angabe in px. Falls das Element eingerückt ist (Einrückungsstufe > 0), ist die Angabe relativ zu (Einrückungsstufe * Einrückung), sonst zum linken Fensterrand. Negative Werte sind möglich. <br>Eine Angabe von _leftmargin_ **überschreibt** gleichzeitig auch das Attribut _leftmargin1_ mit dem selben Wert.
| **leftmargin1**    | Einzug der ersten Zeile, muss **nach _leftmargin_** gesetzt werden. Die Angabe bezieht sich ebenfalls auf den Einrückungsabstand bzw. den linken Fensterrand. Bezug auf _leftmargin_ ist möglich durch z.B. `leftmargin1 = leftmargin + 12`.
| **rightmargin**    | Rechter Rand (in px), gültig für alle Zeilen des Absatzes.
| **topskip**        | Abstand vom vorhergehenden Absatz (in px)
| **bottomskip**     | Abstand zum nachfolgenden Absatz (in px). _topskip_ und _bottomskip_ aufeinanderfolgender Absätze verschmelzen nicht.
| **lineskip**       | Abstand zwischen Zeilen innerhalb des Absatzes. Die Angabe (in px) wird zum vom Font vorgegebenen Zeilenabstand addiert.
| **align**          | Ausrichtung, `left`=linksbündig, `center`=zentriert, `right`=rechtsbündig. Blocksatz ist nicht möglich, da das Tk-Textwidgets diesen nicht unterstützt.
| **bullet**         | Aufzählungszeichen, Bsp. `bullet = ‣` oder `bullet = ""` (kein Aufzählungszeichen setzen). <br>Für nummerierte Listen ist eine Eins im gewünschten Format einzufügen, also: <br>"1" für Zahlen; "A"/"a" für Gross-/Kleinbuchstaben; "I"/"i" für grosse/kleine römische Zahlen; "α" für griechische Kleinbuchstaben. Beispiel: `bullet = "a)"`
| **bulletdistance** | Abstand des Aufzählungszeichens vom Text (erste Zeile). Wenn ein Aufzählungszeichen vorhanden ist, gelten die Angaben _leftmargin_ und _leftmargin1_ weiterhin für den Abstand des Textes. Das Aufzählungszeichen wird um _bulletdistance_ px links vom Textbeginn ausgegeben. Es sollte eine Distanz von mindestens 7 px gewählt werden, weil das Tk-Textwidget eine minimale Breite von Tabulatorzeichen vorschreibt und somit die Ausrichtung des Textes beeinträchtigen würde.
| **bulletcolor** | Farbe des Aufzählungszeichens (Vordergrund).

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

### padding

Syntax: `padding { Attribut-Definitionen }`

Definiert die Abstände, um die jeglicher Textinhalt von den Rändern des Textwidgets entfernt sein soll. Im Unterschied zu den Effekten, die sich mit den Attributen _leftmargin_, _rightmargin_, _topskip_ und _bottomskip_ erreichen lassen, kann man sich den "padding"-Abstand als eine Art **Bilderrahmen** vorstellen. Dieser liegt über dem Textinhalt und kann überschüssige Zeilen verdecken, wenn der Text nicht auf der Widget-Fläche Platz hat, und nimmt nicht die Farbe von Inhalts-Tags an, die eine Hintergrundfarbe setzen. Intern setzen diese Werte die Eigenschaften `-padx -pady`des Tk-Textwidgets.

Die _{ Attribut-Definitionen }_ sind analog zu denen in anderen Fällen, aber **nur die Attribute _x_ und _y_ sind vorhanden**; diese setzen die Breite des linken/rechten bzw. oberen/unteren Randes. Referenzen der Typen _default.\<attr\>_ und _\<linetype\>.\<attr\>_ sind erlaubt. Auf bereits gesetzte Werte von _x_ und _y_ kann ebenfalls Bezug genommen werden, z.B. `x = 4; y = x-3`.

### selection

Syntax: `selection { Attribut-Definitionen }`

Definiert das Aussehen der Auswahl-Markierung. Folgende Attribute werden unterstützt:

| Attribut  | Bedeutung
| --------- | ---------
| **color** | Farbe, mit der ausgewählter Text hinterlegt wird
| **alpha** | Deckkraft/Transparenz der farbigen Hinterlegung, grössere Werte bedeuten mehr Deckkraft. Der Wertebereich ist 0 bis 1.

Referenzen der Typen _default.\<attr\>_ und _\<linetype\>.\<attr\>_ sind erlaubt.

### cursor

Syntax: `cursor { Attribut-Definitionen }`

Definiert das Aussehen der blinkenden Einfügemarke. Folgende Attribute werden unterstützt:

| Attribut    | Bedeutung
| ----------- | ---------
| **color**   | Farbe (Standard: Schwarz)
| **width**   | Breite in px. _Wird die Einfügemarke am linken Rand des Textfensters platziert, wird leider ein Teil abgeschnitten, auch bei grösseren "padding"-Abständen. Dieses Fehlverhalten von Tk kann durch Setzen einer Breite von 1 verborgen werden._
| **ontime**  | Dauer der Blinkphase, in der die Marke sichtbar ist. (Einheit: Millisekunden)
| **offtime** | Dauer der Blinkphase, in der die Marke unsichtbar ist. (Einheit: Millisekunden.) Ein Wert von _0_ bewirkt, dass die Marke nicht blinkt, was für langsame X11-Verbindungen vorteilhaft sein kann.

Referenzen der Typen _default.\<attr\>_ und _\<linetype\>.\<attr\>_ sind erlaubt, sowie Bezug auf bereits gesetzte Attribute, Bsp. `ontime = 500; offtime = ontime - 200`.

### reset

Syntax: `reset`

Dieser "parasitische" (ursprünglich nicht für die Tagsheet-Sprache gedachte) Befehl annulliert alle Einstellungen, die oberhalb von seinem Aufruf getätigt wurden. Er kann nützlich sein für die Fehlersuche in Tagsheets, da er es ermöglicht, einzelne Einstellungen am Ende der Tagsheet-Datei zu testen, ohne den üblichen Inhalt des Tagsheet zu löschen. Eine Alternative hierzu ist `if 0 { }`.


Attribut-Definitionen
---------------------

_Dies ist eine kurze Übersicht. Für Details siehe die [englische Version](README.md#attribute-definitions)._

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
* Allgemein darf nicht auf weiter unten definierte Stile (bzw. Attribute im selben Stil-Block) Bezug genommen werden (sonst könnten Zirkelschlüsse wie `aaa = bbb; bbb = aaa` entstehen). Es ist jedoch ‒ wie in CSS ‒ erlaubt, einen Stil nachträglich mit einem Attributblock zu erweitern. Damit sollten verschiedene Design-Aspekte (Bsp. Positionierung und Farbgebung) besser auseinander gehalten werden können.

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
