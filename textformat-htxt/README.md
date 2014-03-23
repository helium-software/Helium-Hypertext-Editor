Helium Hypertext (.htxt)
========================

Entwurfsziele
-------------
1. Falls keine Zusatzdaten vorliegen, soll sich das Format zu reinem Text *(wie er
   in einem Editor mit automatischem Zeilenumbruch sinnvoll ist)* wegkürzen,
   d.h. keinen Overhead für Auszeichnungsinformationen beinhalten.<br>
   (Umgekehrt: Reiner Text ist valides HTXT und wird interpretiert wie erwartet.)
2. Das Einlesen des Markups soll nie mit einem Fehler abbrechen, höchstens Warnungen.
3. Jeder Absatz enthält alle Informationen, die zu seiner Darstellung benötigt werden.
   Absatzübergreifend verschachtelte Strukturen gibt es nicht.

Zu kodierende Informationen
---------------------------
**1. Text in Form von Absätzen, wobei innerhalb eines Absatzes Zeilenumbrüche
(mit der Semantik von HTMLs \<br\>) vorkommen dürfen.**

* Zeichenkodierung: UTF-8 (falls in den Kopfzeilen nichts anderes festgelegt)

* Absatztrennung:   Zweimal ↵ (Hex 0x0a)

* Zeilenumbruch innerhalb Absatz: Einmal ↵ (Hex 0x0a)

  | Kodierung    | Bedeutung
  | ------------ | -------------------------------------------------------
  | Einmal ↵     | Zeilenumbruch
  | 2-3x ↵       | Neuer Absatz  (1x Absatztrennung)
  | 4-5x ↵       | Leerer Absatz, danach neuer Absatz  (2x Absatztrennung)
  | 6-7x ↵       | 3 Absatztrennungen
  |  ...         |  ...

* Zur Kompatibilität mit _cat_&nbsp; SOLLTE am Ende der Datei ein Zeilenumbruch (↵ 0x0a) stehen,
  dieser schließt die Datei bloß ab (kein \<br\> wird daraus erzeugt).

  | Kodierung    | Bedeutung
  | ------------ | --------------------------------------------------
  | (kein ↵)     | Dateiende OK. Beim Abspeichern wird ein \n angehängt.
  | Einmal ↵     | Dateiende (ignorieren)
  | 2-3x ↵       | Einen leeren Absatz erzeugen
  | 4-5x ↵       | Zwei leere Absätze erzeugen
  |  ...         |  ...

* _Folgerung:_&nbsp; Zeilenumbruch als erstes/letztes Element im Absatz gibt es nicht.<br>
  (Wichtigster Grund: ↵↵↵ ⇒ `<br><p>` oder `<p><br>` ??)<br>
  Für derartige "Holzfällereien" sind die Zeilenumbrüche entsprechend mit Spaces zu trennen.<br>
  ("↵ ↵↵" ⇒ `<br> <p>` ; "↵↵ ↵" ⇒ `<p> <br>`)

* Escaping: `{` `}` sind Codes, die für Markup reserviert sind.

  | Kodierung | Bedeutung
  | --------- | ---------------------------------------------------------
  | `\{`      | Öffnende geschweifte Klammer
  | `\}`      | Schließende geschweifte Klammer
  | `\`       | Backslash (außer für obige Fälle)
  | Daraus folgt:
  | `\\{`     | Backslash, gefolgt von öffnender geschweifter Klammer
  | `\\}`     | Backslash, gefolgt von schließender geschweifter Klammer

  Dies unterscheidet sich von der gewöhnlichen UNIX-Art von Escaping (`\*` -> *),
  scheint mir aber eleganter.


**2. Zusatzinformationen zum ganzen Text, in der Gestalt von Schlüssel/Wert-Paaren**

* Kopfzeilen im Format «Schlüssel: Wert», danach Leerzeile, danach Textinhalt

* Eine Datei darf auch keine Kopfzeilen enthalten. Dies wird anhand der ersten Zeile entschieden:
  Falls die erste Zeile auf das Muster  _(Folge aus Nicht-Abstand):(Abstand)(beliebiger Text)_&nbsp; passt,
  handelt es sich um eine Kopfzeile, sonst ist es die erste Zeile des Inhalts.

  |  Kodierung (jeweils ab Dateianfang)    | Bedeutung
  |  ------------------------------------- | -----------------------------------------------------------------
  |  <code>Hypertext-Test: 1.0<br>Title: Hallo Welt<br><br>Dies ist die erste Zeile.</code> | Schlüssel «Hypertext-Test»  Wert «1.0»<br>Schlüssel «Title»  Wert «Hallo Welt»<br>Text beginnt bei «Dies»
  |  `Hypertext Test: 1.0`                 | Text beginnt bei «Hypertext»
  |  `Title:Hallo`                         | Text beginnt bei «Title»
  |  `Ziel: Ein Format entwickeln, das...` | Schlüssel «Ziel»  Wert «Ein Format entwickeln, das...»
  |  <code><br>Ziel: Ein Format entwickeln, das...</code> | Text beginnt bei «Ziel» (kein Zeilenumbruch davor)

* Schlüssel und Wert sind grundsätzlich Textstrings. Ihre weitere Semantik (Zahl, Datum/Uhrzeit, Liste)
  ist auf dieser Ebene nicht festgelegt, sondern hängt vom Schlüssel ab.
  * **Namensraum für Schlüssel:** alle Zeichen außer Whitespace, Newline, `:`; mindestens 1 Zeichen

* Falls der Wert am Anfang oder Ende Whitespace enthalten soll, ist er in Anführungszeichen (") zu fassen.

  |  Kodierung                    | Bedeutung
  |  ---------------------------- | ------------------------------------------
  |  `Title:   Hallo Welt`        | Schlüssel «Title»  Wert «Hallo Welt»
  |  `Title: "Hallo Welt"`        | Schlüssel «Title»  Wert «Hallo Welt»
  |  `Title: "  Hallo Welt"`      | Schlüssel «Title»  Wert «  Hallo Welt»
  |  `Title: "Hallo Welt`         | Schlüssel «Title»  Wert «"Hallo Welt»
  |  `Title: Er sagte "Hallo"`    | Schlüssel «Title»  Wert «Er sagte "Hallo"»
  |  `Title: " Er sagte "Hallo""` | Schlüssel «Title»  Wert « Er sagte "Hallo"»

* Regel: Falls der um Whitespace 'getrimmte' Wert als erstes UND letztes Zeichen ein " hat, werden diese beiden
       abgeschnitten, und das Innere wird zum Wert.
* ***TODO***: Mehrere Kopfzeilen zum gleichen Schlüssel -> ?


**3. Formatierungs-Anweisungen für Absätze**

* Angabe eines Absatztyps

  | Kodierung                   | Bedeutung
  | --------------------------- | ---------------------------------------------
  | `{heading} Text text text`  | Absatztyp «heading»  Inhalt «Text text text»
  | <code>{heading}&nbsp;  Text text text</code> | Absatztyp «heading»  Inhalt « Text text text»
  | `{heading}Text text text`   | Inhalt «{heading}Text text text»

  * **Namensraum für Absatztypen:** alle Zeichen außer Whitespace, Newline, `|{}=`; mindestens 1 Zeichen

* Angabe weiterer Parameter

  | Kodierung                       | Bedeutung
  | ------------------------------- | -----------------------------------------------------------------------------
  | <code>{list&#124;bullet=ol&#124;level=3} Text</code> | Absatztyp «list», Schlüssel «bullet» Wert «ol», Schlüssel «level» Wert «3»
  | <code>{bullet=ol&#124;level=3} Text</code>      | Standard-Absatz, Schlüssel «bullet» Wert «ol», Schlüssel «level» Wert «3»
  | `{context=warning} Text`        | Standard-Absatz, Schlüssel «context» Wert «warning»

  * **Namensraum für Parameter:** alle Zeichen außer Whitespace, Newline, `|{}=`; mindestens 1 Zeichen
  * **Namensraum für Werte:** alle Zeichen außer Whitespace (***TODO***), Newline, `|{}=`; mindestens 0 Zeichen

  | Kodierung                      | Bedeutung
  | -------------------------------| -----------------------------------------------------------------------
  | `{a=b=c} Text`                   | Schlüssel «a» Wert «c», Schlüssel «b» Wert «c»<br>(weniger intuitive Variante: Standard-Absatz, Schlüssel «a» Wert «b=c»)
  | `{font="Liberation Sans"}`       | Schlüssel «font» Wert (***TODO***)


**4. Formatierungs-Anweisungen für Zeichen innerhalb von Absätzen**

* Angabe eines Zeichenstils<br>
  Muster: `{` + Name + 1 Leerzeichen + Inhalt + `}`

  | Kodierung                     | Bedeutung als HTML
  | ----------------------------- | ------------------------------------------------
  | `{bold Fetter Text}`          | \<bold\>Fetter Text\</bold\>
  | `{big Groß und {big größer}}` | \<big\>Groß und \<big\>größer\</big\>\</big\>
  | `{small {small Winzig}}`      | \<small\>\<small\>Winzig\</small\>\</small\>
  | `{bold {italic Fettkursiv}}`  | \<bold\>\<italic\>Fettkursiv\</italic\>\</bold\>
  | `{emph }`                     | \<emph\>\</emph\>
  | `{emph  }`                    | \<emph\> \</emph\>
  | `{emph  a}`                   | \<emph\> a\</emph\>
  | `{emph a }`                   | \<emph\>a \</emph\>

* Angabe weiterer Parameter<br>
  Nur der Allgemeinheit halber, wird im Helium-Hypertext-Editor nicht gebraucht (***TODO***: für Hyperlink?).<br>
  Die Implementierung soll den ganzen String (z.B. `bold|test=abc`) als Stilname auffassen.

  | Kodierung              | Bedeutung
  | ---------------------- | -----------------------------------------------
  | <code>{bold&#124;test=abc Text}</code> | Zeichenstil «bold», Schlüssel «test» Wert «abc»<br>Alternativ: Zeichenstil «bold&#124;test=abc»
  | `{test=abc Text}`      | Kein Zeichenstil, Schlüssel «test» Wert «abc»<br>Alternativ: Zeichenstil «test=abc»


**5. Andere Inhaltstypen**, z.B. Tabelle, Grafik, Fußnote (wie Zeichenstil, aber FN-Text kann mehrere Absätze umfassen!) ...

| Kodierung         | Bedeutung
| ----------------- | ----------------------------------
| <code>{{TABLE<br>a b c &nbsp; &nbsp; &nbsp; d e<br>f g h i j &nbsp; k l<br>}}</code> | Tabelle (hier 2x2),<br>Tab ⇒ nächste Spalte<br>↵ ⇒ nächste Zeile
| <code>{{IMAGE&#124;TYPE=PNG<br>ft.GEmW,34/Gkoioj<br>hjGuJLHUF45glgUi6<br>}}</code> | Bild (besser externe Datei)<br>Base64 (keine `{` `}`)<br>Tool-Programme, um Bilder ein-/auszubetten

***TODO:***
- Tabellenformatierung
-  Mit Zeichenstilen kann auch `}}` auftauchen!
