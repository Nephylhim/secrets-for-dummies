// Thème touying inspiré de la collection « Pour les nuls » :
// jaune vif, noir, étiquette blanche, losanges.
#import "@preview/touying:0.8.0": *

#let dy-yellow = rgb("#FFD500")
#let dy-black = rgb("#111111")
#let dy-cream = rgb("#FFFBE6")

#let diamond(size: 0.6em, fill: dy-black) = box(
  width: size,
  height: size,
  baseline: size * 0.1,
  rotate(45deg, rect(width: size * 0.7, height: size * 0.7, fill: fill)),
)

#let diamonds(n: 5, fill: dy-black) = box(
  for _ in range(n) { diamond(fill: fill); h(0.25em) },
)

#let label(body, fill: white) = block(
  fill: fill,
  stroke: 3pt + dy-black,
  inset: (x: 1em, y: 0.6em),
  radius: 2pt,
  body,
)

#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let header(self) = align(top, block(
    width: 100%,
    fill: dy-yellow,
    stroke: (bottom: 6pt + dy-black),
    inset: (x: 1.5em, y: 0.7em),
    {
      set text(fill: dy-black, weight: "black", size: 1.1em)
      grid(
        columns: (1fr, auto),
        align: horizon,
        upper(utils.display-current-heading(level: 2, style: auto)),
        diamonds(n: 3),
      )
    },
  ))
  let footer(self) = align(bottom, block(
    width: 100%,
    fill: dy-black,
    inset: (x: 1.5em, y: 0.45em),
    {
      set text(fill: dy-yellow, size: 0.55em, weight: "bold")
      grid(
        columns: (1fr, auto),
        upper(self.info.title),
        context utils.slide-counter.display() + " / " + utils.last-slide-number,
      )
    },
  ))
  let self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
      fill: dy-cream,
      margin: (top: 80pt, bottom: 45pt, x: 40pt),
      header-ascent: 18pt,
      footer-descent: 12pt,
    ),
    config-common(zero-margin-header: true, zero-margin-footer: true),
  )
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})

#let title-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = {
    set align(center + horizon)
    block(width: 100%, fill: dy-black, inset: 0.8em, {
      set text(fill: dy-yellow, weight: "black", size: 0.9em, tracking: 0.15em)
      upper[Collection « pour les nuls »]
    })
    v(1fr)
    label(
      {
        set text(size: 2.4em, weight: "black", fill: dy-black)
        upper(info.title)
      },
    )
    v(0.6em)
    text(size: 1.1em, weight: "bold", info.subtitle)
    v(0.8em)
    diamonds(n: 7)
    v(1fr)
    block(width: 100%, fill: dy-black, inset: 0.8em, {
      set text(fill: dy-yellow, weight: "bold")
      info.author
    })
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: dy-yellow, margin: 0pt, header: none, footer: none),
  )
  touying-slide(self: self, config: config, body)
})

#let new-section-slide(config: (:), body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: dy-yellow, margin: 2.5em, header: none, footer: none),
  )
  touying-slide(
    self: self,
    config: config,
    align(center + horizon, {
      diamonds(n: 5)
      v(0.6em)
      label(
        text(size: 1.8em, weight: "black", upper(utils.display-current-heading(level: 1))),
      )
      v(0.6em)
      diamonds(n: 5)
      body
    }),
  )
})

#let focus-slide(config: (:), body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: dy-black, margin: 2.5em, header: none, footer: none),
  )
  set text(fill: dy-yellow, size: 1.6em, weight: "black")
  touying-slide(self: self, config: config, align(center + horizon, body))
})

#let dummies-theme(
  aspect-ratio: "16-9",
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(paper: "presentation-" + aspect-ratio),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(size: 22pt, fill: dy-black)
        set list(marker: ([#diamond()], [•]))
        show heading: set text(weight: "black")
        show raw: set text(fill: dy-black)
        show link: underline
        body
      },
      alert: (self: none, it) => highlight(fill: dy-yellow, extent: 0.15em, it),
    ),
    config-colors(primary: dy-yellow, neutral-darkest: dy-black),
    ..args,
  )
  body
}
