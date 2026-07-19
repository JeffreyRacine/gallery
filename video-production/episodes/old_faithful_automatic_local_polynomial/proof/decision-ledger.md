# Decision and validation ledger

Jeffrey approved the statistical framing, visual grammar, complete seedless
script, and continuous Cove narration on 2026-07-19.

## Automatic-search contract

The recent `nomad = "auto"` addition is the Gallery's recommended convenience
route for automatic local-polynomial degree and bandwidth selection. It uses
exhaustive Powell-style degree search when the small one-dimensional lattice is
inexpensive and more reliable, while retaining NOMAD for larger or explicitly
requested search surfaces. The verified public `np` 0.70-5 build selects degree
4 and bandwidth 556.863008247459 for this example.

An explicit `nomad = TRUE` comparison selects degree 1 and bandwidth
0.4419183896748617 here. That comparison is retained as mechanism evidence,
not presented as a package defect or as the public recommended route.

## Seedless installed proof

Five clean campaign-library runs used `B = 9999` without calling `set.seed()`.
All selected degrees, bandwidths, objectives, and four-panel images agree
exactly. Each run completed without warnings or messages. The five PNGs share
MD5 `431cedf8ad1bbf2961d1a116366ea187`.

## Narration and accessibility

The approved public narration contains 54 words. Cove used the private cue
`Bon-ferr-OH-nee`; all public text retains `Bonferroni`. The 23.65-second master
is one uninterrupted take with no splice or time stretching. Captions were
manually aligned to the retained word timings and checked against the approved
public transcript.

## Promotion boundary

Jeffrey approved the exact public bundle and rendered Gallery diff and
authorized commit and push on 2026-07-19. Live GitHub Pages verification
remains a post-push publication check.
