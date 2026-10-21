// Front cover: full-bleed cover image as the very first page of the book.
#page(
  margin: 0pt,
  numbering: none,
)[
  #image("../images/cover/front_cover.jpg", width: 100%, height: 100%, fit: "cover")
]

#pagebreak()

#align(center + horizon)[
  #v(2cm)
  #text(size: 28pt, weight: "bold")[R for Health Economics and Outcomes Research (HEOR) and Health Technology Assessment (HTA)]

  #v(1.5cm)
  #text(size: 14pt, style: "italic")[A practical, reproducible guide to decision-analytic modelling, evidence synthesis, and HTA submission workflows in R]

  #v(3cm)
  #text(size: 13pt)[Dr Aswath Karunakaran]
]
