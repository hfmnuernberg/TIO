\version "2.24.3"

\header {
  tagline = ""
}

\relative c' {
  \omit Staff.TimeSignature
  \omit Staff.Clef
  \omit Staff.BarLine
  \override Staff.StaffSymbol.transparent = ##t
  
  e1
  e1.
  
  \break
  
  e2
  e2.
  \tuplet 3/2 {e2}
  
  \break
  
  e4
  e4.
  \tuplet 3/2 {e4}
  
  \break
  
  e8
  e8.
  \tuplet 3/2 {e8}
  \tuplet 5/2 {e8}
  \tuplet 7/2 {e8}
  
  \break
  
  e16
  e16.
  \tuplet 3/2 {e16}
  \tuplet 5/2 {e16}
  \tuplet 7/2 {e16}
  
  \break
  
  e32
  e32.
  \tuplet 3/2 {e32}
  \tuplet 5/2 {e32}
  \tuplet 7/2 {e32}
  
  \break
  
}