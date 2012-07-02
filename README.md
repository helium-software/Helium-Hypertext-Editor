Helium-Content-Editor
=====================

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
* Index by Category; alphabetical index; custom welcom page
* Photo spreads (for e.g. screenshot series); index of those
* Software download area (directory browser with added descriptions)
* Self-made Ttk (Tile) GUI theme to make the editor feel like Helium

Development Roadmap
-------------------
0. Import/adapt Auto-loading infrastructure from tcl-misc repository
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
