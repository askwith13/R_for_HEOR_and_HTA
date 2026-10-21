// Back cover: author portrait and closing quote, final page of the book.
#page(
  margin: 0pt,
  numbering: none,
)[
  #set page(fill: rgb("#1a1a1a"))
  #align(center + horizon)[
    #v(1.5cm)
    #box(
      clip: true,
      radius: 4pt,
      image("../images/cover/back_cover.jpg", width: 62%),
    )

    #v(1.8cm)
    #block(width: 78%)[
      #align(center)[
        #text(size: 14pt, style: "italic", fill: rgb("#f0f0f0"))[
          "Treat people as if they were what they ought to be and you help them
          to become what they are capable of being."
        ]

        #v(0.6cm)
        #text(size: 11pt, fill: rgb("#cfcfcf"))[--- Johann Wolfgang von Goethe]
      ]
    ]

    #v(1.5cm)
    #text(size: 10pt, fill: rgb("#9a9a9a"))[Dr Aswath Karunakaran]
  ]
]
