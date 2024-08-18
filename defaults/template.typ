#let only(values) = {
  assert(values.len() == 1, message: "Expected an array of length 1")
  values.first()
}

#set page(
  paper: "a5",
  margin: (top: 13mm, bottom: 16mm),
)

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  it
  v(1em)
}

$if(pdf-footer)$
$pdf-footer$
$endif$

#show raw.where(block: true): it => block(
  fill: rgb("#f7f7f7"),
  width: 100%,
  inset: 8pt,
  radius: 5pt,
  text(size: 7pt, it)
)

$if(titlepage)$
#align(center)[
  #v(4em)
  #text(size: 30pt)[
    $title$
  ]

  $if(subtitle)$
  #v(1em)
  #text(size: 20pt)[
    $subtitle$
  ]
  $endif$

  #v(2em)
  $for(author)$
  #text(size: 14pt)[
    $author$
  ]
  $endfor$
]
$endif$

$if(titlepage)$
#pagebreak()
$titlepage-top$

#align(bottom)[
  #text(size: 8pt)[
  $if(titlepage-bottom)$
  $titlepage-bottom$
  $endif$

  Version: $build-info$

  $if(pdf-license)$
  $pdf-license$
  $endif$
  ]
]
$endif$

$if(toc)$
$if(tocdepth)$
#outline(depth: $tocdepth$)
$else$
#outline(depth: 1)
$endif$
#pagebreak()
$endif$

#set page(
  footer: context {
    set text(size: 9pt)
    let num = only(counter(page).get())
    let is_left_page = calc.even(num)
    if is_left_page [
      #num
    ] else [
      #h(1fr)
      #num
    ]
  }
)

#counter(page).update(1)

$if(links-as-notes)$
#show link: it => [
  #if type(it.dest) == str [
    #it.body#footnote[#it.dest] #h(-0.2em)
  ] else [
    #it
  ]
]
$endif$

$body$

$if(bibliography)$

#bibliography($for(bibliography)$"$bibliography$"$sep$,$endfor$)
$endif$
