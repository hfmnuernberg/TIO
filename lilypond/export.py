import os
import subprocess

# List of notes
notes = {
    "e1": 4,
    "e1.": 6,
    "e2": 2,
    "e2.": 3,
    "e4": 1,
    "e4.": 1.5,
    "e8": 4 / 8,
    "e8.": (4 / 8) * 1.5,
    "e16": 4 / 16,
    "e16.": (4 / 16) * 1.5,
    "e32": 4 / 32,
    "e32.": (4 / 32) * 1.5,
    # half
    "\\tuplet 3/2 {e2}": 4 / 3,
    # quarter
    "\\tuplet 3/2 {e4}": 2 / 3,
    # eigth
    "\\tuplet 3/2 {e8}": 1 / 3,
    "\\tuplet 5/2 {e8}": 2 / 5,
    "\\tuplet 6/2 {e8}": 2 / 6,
    "\\tuplet 7/2 {e8}": 2 / 7,
    # sixteenth
    "\\tuplet 3/2 {e16}": 0.5 / 3,
    "\\tuplet 5/2 {e16}": 1 / 5,
    "\\tuplet 6/2 {e16}": 1 / 6,
    "\\tuplet 7/2 {e16}": 1 / 7,
}

# LilyPond template
template = """
\\version "2.24.3"

\\header {{
  tagline = ""
}}

\\relative c' {{
  \\omit Staff.TimeSignature
  \\omit Staff.Clef
  \\omit Staff.BarLine
  \\override Staff.StaffSymbol.transparent = ##t
  
  {}
}}
"""

# Create a subfolder for the SVG files
os.makedirs("svg_files", exist_ok=True)

# Create a LilyPond file for each note and export as SVG
for note, length in notes.items():
    # Create LilyPond file
    with open("note.ly", "w") as f:
        f.write(template.format(note))

    # Export as SVG
    subprocess.run(["lilypond", "-dbackend=svg", "-dpreview", "note.ly"])

    # Replace special characters in note name
    note_name = note.replace("\\", "").replace("/", "_").replace(" ", "_").replace("{", "").replace("}", "")
    note_name += f"_{length}"

    # Move SVG file to subfolder and rename it
    os.rename("note.preview.svg", f"svg_files/{note_name}.svg")

# Delete LilyPond file
os.remove("note.ly")
