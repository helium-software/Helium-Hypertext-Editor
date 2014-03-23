Helium Hypertext (.htxt)

Entwurfsziele
-------------
> Falls keine Zusatzdaten vorliegen, soll sich das Format zu reinem Text wegkürzen.
  (Umgekehrt: Reiner Text ist valides HTXT und wird interpretiert wie erwartet.)
  [Reiner Text = 'Text wie er in einem zeilenumbruch-fähigen Editor Sinn macht']

> Das Einlesen des Markups soll nie mit einem Fehler abbrechen, höchstens Warnungen.

> Jeder Absatz enthält alle Informationen, die zu seiner Darstellung benötigt werden.
  Absatzübergreifend verschachtelte Strukturen gibt es nicht.

Zu kodierende Informationen
---------------------------
> Text in Form von Absätzen, wobei innerhalb eines Absatzes Zeilenumbrüche
  (mit der Semantik von HTMLs <br>) vorkommen dürfen.
    * Zeichenkodierung: UTF-8 (falls in den Kopfzeilen nichts anderes festgelegt)
    * Absatztrennung:   Zweimal \n (Hex 0x0a)
    * Zeilenumbruch innerhalb Absatz: Einmal \n (Hex 0x0a)
        Kodierung    | Bedeutung
        ------------ | -------------------------------------------------------
        Einmal \n    | Zeilenumbruch
        2-3x \n      | Neuer Absatz  (1x Absatztrennung)
        4-5x \n      | Leerer Absatz, danach neuer Absatz  (2x Absatztrennung)
        6-7x \n      | 3 Absatztrennungen
         ...         |  ...
    * Zur Kompatibilität mit 'cat' SOLLTE am Ende der Datei ein Zeilenumbruch (\n 0x0a) stehen,
      dieser schliesst die Datei bloss ab (kein <br> wird daraus erzeugt).
        Kodierung    | Bedeutung
        ------------ | --------------------------------------------------
        (kein \n)    | Dateiende OK. Beim Abspeichern wird ein \n angehängt.
        Einmal \n    | Dateiende (ignorieren)
        2-3x \n      | Einen leeren Absatz erzeugen
        4-5x \n      | Zwei leere Absätze erzeugen
         ...         |  ...
    * Folgerung: Zeilenumbruch als erstes/letzes Element im Absatz gibt es nicht.
      (Wichtigster Grund: \n\n\n -> <br><p> oder <p><br> ??)
      Für derartige "Holzfällereien" sind die "\n"s entsprechend mit Spaces zu trennen.
      ("\n \n\n" -> <br><p> ; "\n\n \n" -> <p><br>)

    * Escaping: { } sind Codes, die für Markup reserviert sind.
        Kodierung | Bedeutung
        --------- | ---------------------------------------------------------
        \{        | Öffnende geschweifte Klammer
        \}        | Schliessende geschweifte Klammer
        \         | Backslash (ausser für obige Fälle)
	Daraus folgt:
        \\{       | Backslash, gefolgt von öffnender geschweifter Klammer
        \\}       | Backslash, gefolgt von schliessender geschweifter Klammer
      Dies unterscheidet sich von der gewöhnlichen UNIX-Art von Escaping (\* -> *),
      scheint mir aber eleganter.

> Zusatzinformationen zum ganzen Text, in der Gestalt von Schlüssel/Wert-Paaren
  * Kopfzeilen im Format "Schlüssel: Wert", danach Leerzeile, danach Textinhalt
  * Eine Datei darf auch keine Kopfzeilen enthalten. Dies wird anhand der ersten Zeile entschieden:
    Falls die erste Zeile auf das Muster  (Folge aus Nicht-Abstand):(Abstand)(beliebiger Text) passt,
    handelt es sich um eine Kopfzeile, sonst ist es die erste Zeile des Inhalts.
       Kodierung (jeweils ab Dateianfang)    | Bedeutung
       ------------------------------------- | -----------------------------------------------------------------
       Hypertext-Test: 1.0                   | Schlüssel "Hypertext-Test"  Wert "1.0"
       Title: Hallo Welt                     | Schlüssel "Title"  Wert "Hallo Welt"
                                             |
       Dies ist die erste Zeile.             | Text beginnt hier
       ------------------------------------- | -----------------------------------------------------------------
       Hypertext Test: 1.0                   | Text beginnt hier
       ------------------------------------- | -----------------------------------------------------------------
       Title:Hallo                           | Text beginnt hier
       ------------------------------------- | -----------------------------------------------------------------
       Ziel: Ein Format entwickeln, das...   | Schlüssel "Ziel"  Wert "Ein Format entwickeln, das..."
       ------------------------------------- | -----------------------------------------------------------------
                                             | 
       Ziel: Ein Format entwickeln, das...   | Text beginnt hier (erster Absatz, kein Zeilenumbruch vor "Ziel:")
  * Schlüssel und Wert sind grundsätzlich Textstrings. Ihre weitere Semantik (Zahl, Datum/Uhrzeit, Liste)
    ist auf dieser Ebene nicht festgelegt, sondern hängt vom Schlüssel ab.
    # Namensraum für Schlüssel: alle Zeichen ausser Whitespace, Newline, «:»; mindestens 1 Zeichen
  * Falls der Wert am Anfang oder Ende Whitespace enthalten soll, ist er in Anführungszeichen (") zu fassen.
       Kodierung                  | Bedeutung
       -------------------------- | ------------------------------------------
       Title:   Hallo Welt        | Schlüssel «Title»  Wert «Hallo Welt»
       Title: "Hallo Welt"        | Schlüssel «Title»  Wert «Hallo Welt»
       Title: "  Hallo Welt"      | Schlüssel «Title»  Wert «  Hallo Welt»
       Title: "Hallo Welt         | Schlüssel «Title»  Wert «"Hallo Welt»
       Title: Er sagte "Hallo"    | Schlüssel «Title»  Wert «Er sagte "Hallo"»
       Title: " Er sagte "Hallo"" | Schlüssel «Title»  Wert « Er sagte "Hallo"»
    Regel: Falls der um Whitespace 'getrimmte' Wert als erstes UND letztes Zeichen ein " hat, werden diese beiden
           abgeschnitten, und das Innere wird zum Wert.
  * TODO: Mehrere Kopfzeilen zum gleichen Schlüssel -> ?

> Formatierungs-Anweisungen für Absätze
  * Angabe eines Absatztyps
       Kodierung                  | Bedeutung
       -------------------------- | ---------------------------------------------
       {heading} Text text text   | Absatztyp «heading»  Inhalt «Text text text»
       {heading}  Text text text  | Absatztyp «heading»  Inhalt « Text text text»
       {heading}Text text text    | Inhalt «{heading}Text text text»
    # Namensraum für Absatztypen: alle Zeichen ausser Whitespace, Newline, «|{}=»; mindestens 1 Zeichen
  * Angabe weiterer Parameter
       Kodierung                      | Bedeutung
       ------------------------------ | -----------------------------------------------------------------------------
       {list|bullet=ol|level=3} Text  | Absatztyp «heading», Schlüssel «bullet» Wert «ol», Schlüssel «level» Wert «3»
       {bullet=ol|level=3} Text       | Standard-Absatz, Schlüssel «bullet» Wert «ol», Schlüssel «level» Wert «3»
       {context=warning} Text         | Standard-Absatz, Schlüssel «context» Wert «warning»
    # Namensraum für Parameter: alle Zeichen ausser Whitespace, Newline, «|{}=»; mindestens 1 Zeichen
    # Namensraum für Werte: alle Zeichen ausser Whitespace (TODO), Newline, «|{}=»; mindestens 0 Zeichen
       Kodierung                      | Bedeutung
       -------------------------------| -----------------------------------------------------------------------
       {a=b=c} Text                   | Schlüssel «a» Wert «c», Schlüssel «b» Wert «c»
                                      | (weniger intuitive Variante: Standard-Absatz, Schlüssel «a» Wert «b=c»)
       {font="Liberation Sans"}       | Schlüssel «font» Wert (TODO)
       {font=Liberation_Sans}         | (TODO)

> Formatierungs-Anweisungen für Zeichen innerhalb von Absätzen
  * Angabe eines Zeichenstils
    Muster: { + Name + 1 Leerzeichen + Inhalt + }
       Kodierung                     | Bedeutung als HTML
       ----------------------------- | ----------------------------------------
       {bold Fetter Text}            | <bold>Fetter Text</bold>
       {big Gross und {big grösser}} | <big>Gross und <big>grösser</big></big>
       {small {small Winzig}}        | <small><small>Winzig</small></small>
       {bold {italic Fettkursiv}}    | <bold><italic>Fettkursiv</italic></bold>
       {emph }                       | <emph></emph>
       {emph  }                      | <emph> </emph>
       {emph  a}                     | <emph> a</emph>
       {emph a }                     | <emph>a </emph>
  * Angabe weiterer Parameter
    Nur der Allgemeinheit halber, wird im Helium-Hypertext-Editor nicht gebraucht.
    -TODO: für Hyperlink?
    Die Implementierung soll den ganzen String (z.B. "bold|test=abc") als Stilname auffassen.
       Kodierung            | Bedeutung
       -------------------- | -----------------------------------------------
       {bold|test=abc Text} | Zeichenstil «bold», Schlüssel «test» Wert «abc»
                            | Alternativ: Zeichenstil «bold|test=abc»
       -------------------- | -----------------------------------------------
       {test=abc Text}      | Kein Zeichenstil, Schlüssel «test» Wert «abc»
                            | Alternativ: Zeichenstil «test=abc»

> Andere Inhaltstypen
  z.B. Tabelle, Grafik, Fussnote (wie Zeichenstil, aber FN-Text kann mehrere Absätze umfassen!) ...
       Kodierung         | Bedeutung
       ----------------- | ----------------------------------
       {{TABLE           | Tabelle (hier 2x2),
       a b c    d e      | Tab-> nächste Spalte
       f g h i j    k l  | \n -> nächste Zeile
       }}                |
       ----------------- | ----------------------------------
       {{IMAGE|TYPE=PNG  | Bild (besser externe Datei)
       ft.GEmW,34/Gkoioj | Base64 (keine { })
       hjGuJLHUF45glgUi6 | Möglichkeiten, mit Tool-Programmen
       }}                | Bilder ein-/auszubetten
TODO
 - Tabellenformatierung
 -  Mit Zeichenstilen kann auch }} auftauchen!
