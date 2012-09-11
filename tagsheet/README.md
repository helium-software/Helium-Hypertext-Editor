Tagsheets
=========

[(springe zur deutschen Version)](#tagsheets-deutsch)

The Native Data Format is designed to allow the _use_ of arbitrary paragraph and character styles, specified through their names, e.g. `bold`. (Usage of undefined styles leads to verbatim output of the corresponding markup, because the parser is designed to always succeed.) The _definition_ of those styles is performed by another file, called the **tagsheet**. It lists the available styles, along with instructions on their presentation in the text widget (WYSIWYM mode). A website project typically has a single central tagsheet. The interpretation of the tags during translation into other formats (HTML, TeX etc.) is _not_ part of the tagsheets; it is specified in **template files**, one for each format.

Example
-------

```
linetype h1 {
	size = 20
	bold = true
	margin-top = 5 ; margin-bottom = 3
}
inlinetag emph {
	italic = parent.italic xor 1
	italic toggle  ;#alternative Definition
}
inlinetag big {
	size = parent.size + 4
	size += 4      ;#alternative Definition
}
inlinetag bold no-cascade {
	bold = true
}
```

Tagsheets (deutsch)
===================

Das Native Datenformat sieht die _Verwendung_ beliebiger Absatz- und Zeichenstile vor, die durch ihren Namen (z.B. `bold`) spezifiziert werden. (Nicht definierte Stile führen zu einer Ausgabe des betreffenden Markup als Reintext, da der Parser nie einen Fehler zurückgeben soll.) Die _Definition_ der Absatz- und Zeichenstile übernimmt eine weitere Datei, das sogenannte **Tagsheet**. Darin werden die vorhandenen Stile aufgezählt, zusammen mit Anweisungen zu deren Darstellung im Textwidget (WYSIWYM-Modus). Typischerweise hat ein Webseiten-Projekt genau ein zentrales Tagsheet. Die Funktion der Tags bei der Ausgabe in andere Formate (HTML, TeX etc.) ist _nicht_ Bestandteil des Tagsheets, sondern wird für jedes Format in einer **Template-Datei** vermerkt.

Beispiel
--------

```
linetype h1 outside-list {
	size = 20
	bold = true
	margin-top = 5 ; margin-bottom = 3
}
inlinetag emph {
	italic = parent.italic xor 1
	italic toggle  ;#alternative Definition
}
inlinetag big {
	size = parent.size + 4
	size += 4      ;#alternative Definition
}
inlinetag bold no-cascade {
	bold = true
}
```

Aufbau
------

Ein Tagsheet ist ein Tcl-Skript, dem spezielle Befehle zur Verfügung stehen (und gewisse gefährliche Befehle nicht). Es besteht aus einer Folge von Stil-Definitionen (Befehl `linetype` oder `inlinetag`) und Spezial-Statements (`listindent` etc.), für komplexe Fälle stehen auch Standard-Tcl-Befehle wie `set` oder `lindex` zur Verfügung.

### linetype

Syntax: `linetype <Name> ?outside-list? { Attribut-Defintionen }`

Definiert einen Absatz-Stil <Name> und setzt dessen Darstellungsattribute. Falls das Argument `outside-list` angegeben wird, kann der Absatz-Stil nur auf Einrückungsstufe 0 ("nicht in einer Liste") vorkommen. Dies ist für Überschriften sinnvoll, sollte aber sonst vorsichtig eingesetzt werden.

### inlinetag

Syntax: `inlinetag <Name> ?no-cascade? { Attribut-Definitionen }`

Definiert einen Zeichen-Stil <Name> und setzt dessen Darstellungsattribute. Falls das Argument `no-cascade` angegeben wird, kann der Zeichen-Stil nicht in sich selbst geschachtelt werden (z.B. ist die Auszeichnung "fett" in fettem Text sinnlos).

Wie im Beispiel ersichtlich, kann innerhalb einer Stil-Definition eine Reihe von Attributen gesetzt werden. Es folgt eine Liste der existierenden Attribute.