Helium Hypertext Editor
=======================

[(springe zur deutschen Version)](#helium-hypertext-editor-deutsch)

This is the Content Management System for the upcoming Helium website.
Unlike typical projects that coined the "CMS" notion, the Helium
Content editor is not a web application at all: editing takes place
in a graphical Tcl/Tk application, and the application emits static
HTML pages (wherever possible).

The application shall implement some innovative user interface ideas
that should give an idea about how the actual Helium will feel like,
and provide (by me using the Content Editor regularly) some feedback
about their usability.

Planned features
----------------

* Editing articles in a WYSIWYM fashion (customized Tk text widget)
  where one can track all formatting markup, not only the printable
  characters (inspired by TeXmacs)
* Human-readable native data format that supports custom character
  and paragraph tags, defined by tagfiles
* Translation of this data format into many target formats, like
  (X)HTML, TeX, plain text, Markdown etc.
* Configuration of file storage locations; multiple repository
  and presentation locations are possible, local and remote;
  integration of syncing protocols (Rsync, ssh/scp, FTP) and Git
  (if applicable)
* Data organisation based on Categories, where one article can belong
  to more than one Category (a.k.a. tag, as on StackOverflow.com)
* Visitor comments
* Index by Category; alphabetical index; custom welcome page
* Photo spreads (for e.g. screenshot series); index of those
* Software download area (directory browser with added descriptions)
* Self-made Ttk (Tile) GUI theme to make the editor feel like Helium

Development Roadmap
-------------------
0. _(Done)_ Import/adapt Auto-loading infrastructure from tcl-misc repository
1. Tagsheet parser (safe interpreter); method to apply tags
   hierarchically to a text widget
2. Native Data format parser; highlighting source editor widget
   (helps to see if the parser works correctly)
3. Compiling Native Data Format to a tree for the WYSIWYM view,
   serializing a tree back to Native Data Format
4. Methods for manipulating content trees and interacting with
   the text widget (last step: widget bindings)
5. Main Interface and GUI
6. Repository support, project configuration files
7. Images and hyperlinks; visitor comments; remaining page types

-----------------------------------------------------------------------------

Helium-Hypertext-Editor (deutsch)
=================================

Dies ist die Inhaltsverwaltung für den zukünftigen Helium-Webauftritt.
Anders als typische Projekte, die den Begriff "CMS" prägten, ist
der Helium Content Editor gar keine Web-Applikation: Die Bearbeitung
von Inhalten geschieht in einem graphischen Tcl/Tk-Programm, welches
statische HTML-Seiten (soweit irgend möglich) ausgibt und auf den
Server hochlädt.

Das Programm soll einige innovative Ideen in seiner Benutzerschnittstelle
implementieren, die bereits eine Ahnung davon geben sollten, wie das
eigentliche Helium sich anfühlen wird, und mir etwas Rückmeldungen über
ihre Brauchbarkeit geben werden (dadurch, dass ich den Content Editor
regelmäßig benutze).

Geplante Funktionen
-------------------

* Artikel bearbeiten nach dem WYSIWYM-Konzept (angepasstes Tk-Textwidget),
  wo sich auch alle Formatierungsdaten verfolgen lassen, statt nur die
  druckbaren Zeichen (inspiriert von TeXmacs)
* Textbasiertes natives Datenformat, das die Definition beliebiger
  Zeichen- und Absatzstile unterstützt, basierend auf _Tagfiles_
* Übersetzung dieses Formats in verschiedene Zielformate, z.B. (X)HTML,
  TeX, Reintext, Markdown usw.
* Konfigurierbare (auch mehrfache) Ablageorte für die Seitendaten und deren
  Veröffentlichung, lokal und entfernt; Integration von
  Synchronisationsprotokollen (Rsync, SSH/scp, FTP) und Git (sofern sinnvoll)
* Organisation der Daten basierend auf Kategorien, wobei ein Artikel zu mehr
  als einer Kategorie gehören kann (das Konzept ist als "Tags" bekannt, zum
  Beispiel auf StackOverflow.com)
* Besucher-Kommentare
* Index-Seiten: nach Kategorie, alphabetisch; anpassbare Willkommen-Seite
* Bildstrecken (z.B. Screenshot-Reihen); Index von diesen
* Software-Downloadbereich (Verzeichnis-Browser mit zusätzlichen
  Beschreibungen)
* Selbstgemachtes TTk (Tile)-Thema für die Benutzeroberfläche, damit der
  Editor wie Helium ausschaut.

Entwicklungs-Fahrplan
---------------------
0. _(Abgeschlossen)_ Auto-Load-Infrastruktur vom Repository "tcl-misc"
   importieren/anpassen
1. Parser für Tagsheets (sicherer Interpreter); Methode, um Tags geschachtelt
   auf ein Textwidget anzuwenden
2. Parser für das native Datenformat; Quelltext-Editor mit Syntax-Hervorhebung
   (hilft zu verifizieren, dass der Parser korrekt arbeitet)
3. Natives Datenformat in eine Baumstruktur für die WYSIWYM-Ansicht
   kompilieren, Baumstruktur wieder ins native Datenformat zurück serialisieren
4. Methoden zur Manipulation von Inhalts-Baumstrukturen und zur Interaktion
   mit dem Text-Widget (letzter Schritt: Ereignis-Anbindungen, Tastendrücke
   etc.)
5. Haupt-Benutzerschnittstelle (GUI)
6. Betrieb von Ablageorten, Projekt-Konfigurationsdateien
7. Bilder und Hyperlinks; Besucher-Kommentare; übrige Seitentypen