# LaTeX Style Extensions Reference

Custom CSS that goes beyond LaTeX.css to capture more of LaTeX's visual language.

Copy this file or individual blocks into your project as `latex-extensions.css`.

---

## Complete Extensions Stylesheet

```css
/* ===========================================
   LATEX STYLE EXTENSIONS
   Extends LaTeX.css with additional environments,
   typography, and layout patterns.
   
   Load AFTER latex.css:
   <link rel="stylesheet" href="https://latex.vercel.app/style.css">
   <link rel="stylesheet" href="latex-extensions.css">
   =========================================== */

/* -------------------------------------------
   ADDITIONAL THEOREM-LIKE ENVIRONMENTS
   ------------------------------------------- */

article {
  counter-reset:
    corollary
    remark
    example
    proposition
    conjecture
    axiom
    notation
    algorithm
    listing
    figure;
}

.corollary,
.proposition,
.conjecture,
.axiom {
  font-style: italic;
  display: block;
  margin: 1em 0;
}

.corollary { counter-increment: corollary; }
.proposition { counter-increment: proposition; }
.conjecture { counter-increment: conjecture; }
.axiom { counter-increment: axiom; }

.corollary::before { content: "Corollary " counter(corollary) ". "; font-weight: bold; font-style: normal; }
.proposition::before { content: "Proposition " counter(proposition) ". "; font-weight: bold; font-style: normal; }
.conjecture::before { content: "Conjecture " counter(conjecture) ". "; font-weight: bold; font-style: normal; }
.axiom::before { content: "Axiom " counter(axiom) ". "; font-weight: bold; font-style: normal; }

.remark,
.example,
.notation {
  display: block;
  margin: 1em 0;
}

.remark { counter-increment: remark; }
.example { counter-increment: example; }
.notation { counter-increment: notation; }

.remark::before { content: "Remark " counter(remark) ". "; font-style: italic; }
.example::before { content: "Example " counter(example) ". "; font-weight: bold; }
.notation::before { content: "Notation " counter(notation) ". "; font-weight: bold; }

/* Named theorems: <div class="theorem" data-name="Cantor"> */
.theorem[data-name]::before { content: "Theorem " counter(theorem) " (" attr(data-name) "). "; }
.lemma[data-name]::before { content: "Lemma " counter(lemma) " (" attr(data-name) "). "; }
.corollary[data-name]::before { content: "Corollary " counter(corollary) " (" attr(data-name) "). "; }
.proposition[data-name]::before { content: "Proposition " counter(proposition) " (" attr(data-name) "). "; }


/* -------------------------------------------
   ALGORITHM / PSEUDOCODE
   ------------------------------------------- */

.algorithm {
  border: 1px solid currentColor;
  padding: 1em 1.5em;
  margin: 1.5em 0;
  counter-increment: algorithm;
  page-break-inside: avoid;
}

.algorithm > figcaption {
  font-weight: bold;
  margin-bottom: 0.75em;
  text-align: left;
}

.algorithm > figcaption::before {
  content: "Algorithm " counter(algorithm) ": ";
}

.pseudocode {
  font-family: 'Computer Modern Typewriter', 'Courier New', monospace;
  font-size: 0.9em;
  line-height: 1.5;
  white-space: pre;
  overflow-x: auto;
  margin: 0;
  padding: 0;
  border: none;
  background: none;
}

.pseudocode b {
  font-family: 'Computer Modern Sans', 'Helvetica Neue', sans-serif;
  font-weight: bold;
}


/* -------------------------------------------
   CODE LISTINGS
   ------------------------------------------- */

.listing {
  counter-increment: listing;
  margin: 1.5em 0;
}

.listing > figcaption {
  font-size: 0.875em;
  margin-bottom: 0.25em;
}

.listing > figcaption::before {
  content: "Listing " counter(listing) ": ";
  font-weight: bold;
}

.listing pre {
  border: 1px solid #ddd;
  padding: 0.75em 1em;
  font-size: 0.85em;
  line-height: 1.4;
  overflow-x: auto;
  margin: 0;
}


/* -------------------------------------------
   EPIGRAPH
   ------------------------------------------- */

.epigraph {
  margin: 2em 0;
  padding-left: 2em;
  max-width: 60%;
  margin-left: auto;
  font-style: italic;
  border: none;
}

.epigraph footer,
.epigraph cite {
  font-style: normal;
  text-align: right;
  margin-top: 0.25em;
  font-size: 0.875em;
  display: block;
}

.epigraph footer::before,
.epigraph cite::before {
  content: "— ";
}


/* -------------------------------------------
   TITLE PAGE
   ------------------------------------------- */

.title-page {
  min-height: 75vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  padding: 4rem 2rem;
  margin-bottom: 2rem;
}

.title-page h1 {
  font-size: 2.488em;
  line-height: 1.2;
  margin-bottom: 2rem;
}

.title-page h1::before {
  content: none; /* No section number on title */
}

.title-page .author {
  font-size: 1.2em;
  margin-bottom: 0.5em;
}

.title-page .date {
  font-size: 1em;
  margin-bottom: 0.5em;
}

.title-page .subtitle {
  font-style: italic;
  color: #666;
  margin-top: 1em;
}

.title-page .affiliation {
  font-size: 0.875em;
  color: #555;
}


/* -------------------------------------------
   TABLE OF CONTENTS
   ------------------------------------------- */

.toc {
  margin: 2em 0;
  padding: 1em 0;
  border-top: 1px solid currentColor;
  border-bottom: 1px solid currentColor;
}

.toc h2::before {
  content: none; /* No number on "Contents" heading */
}

.toc ol {
  list-style: none;
  padding-left: 0;
  counter-reset: toc-section;
}

.toc > ol > li {
  counter-increment: toc-section;
  margin-bottom: 0.25em;
}

.toc > ol > li::before {
  content: counter(toc-section) "\2003";
  font-weight: bold;
  display: inline-block;
  width: 2em;
}

.toc ol ol {
  padding-left: 2em;
  counter-reset: toc-subsection;
}

.toc ol ol li {
  counter-increment: toc-subsection;
}

.toc ol ol li::before {
  content: counter(toc-section) "." counter(toc-subsection) "\2003";
  display: inline-block;
  width: 3em;
  font-weight: normal;
}

.toc a {
  text-decoration: none;
  color: inherit;
}

.toc a:hover {
  text-decoration: underline;
}


/* -------------------------------------------
   BIBLIOGRAPHY
   ------------------------------------------- */

.bibliography {
  padding-left: 2em;
  font-size: 0.875em;
}

.bibliography li {
  margin-bottom: 0.5em;
  line-height: 1.4;
}

.bibliography cite {
  font-style: italic;
}

/* Author-year style citations */
.cite-authoryear {
  list-style: none;
  padding-left: 2em;
}

.cite-authoryear li {
  text-indent: -2em;
  padding-left: 2em;
}


/* -------------------------------------------
   MARGIN NOTES
   ------------------------------------------- */

.margin-note {
  float: right;
  clear: right;
  margin-right: -25ch;
  width: 20ch;
  font-size: 0.8em;
  line-height: 1.3;
  color: #666;
}

@media (max-width: 1100px) {
  .margin-note {
    float: none;
    display: block;
    margin: 0.5em 0 0.5em 2em;
    padding-left: 1em;
    border-left: 2px solid #ddd;
    width: auto;
  }
}


/* -------------------------------------------
   LETTER CLASS
   ------------------------------------------- */

.latex-letter {
  max-width: 65ch;
  margin: 4rem auto;
  padding: 0 2rem;
}

.letter-sender {
  text-align: right;
  margin-bottom: 2rem;
}

.letter-recipient {
  margin-bottom: 2rem;
}

.letter-opening {
  margin-bottom: 1em;
}

.letter-closing {
  margin-top: 2em;
}

.letter-signature {
  margin-top: 3em;
}


/* -------------------------------------------
   APPENDIX
   ------------------------------------------- */

.appendix-rule {
  margin: 3em 0 2em;
  border: none;
  border-top: 1px solid currentColor;
}


/* -------------------------------------------
   PRINT STYLES
   ------------------------------------------- */

@media print {
  body {
    font-size: 10pt;
    line-height: 1.2;
    max-width: none;
    margin: 0;
    padding: 0;
  }

  .title-page {
    min-height: auto;
    page-break-after: always;
  }

  h2 {
    page-break-after: avoid;
  }

  .theorem, .lemma, .definition, .proof,
  .corollary, .proposition {
    page-break-inside: avoid;
  }

  figure, .algorithm, .listing {
    page-break-inside: avoid;
  }

  a {
    color: inherit;
    text-decoration: none;
  }

  /* Show URLs for links in print */
  a[href^="http"]::after {
    content: " (" attr(href) ")";
    font-size: 0.8em;
    color: #666;
  }

  .sidenote {
    float: none;
    display: inline;
  }
}


/* -------------------------------------------
   LATEX SIZE COMMANDS (utility classes)
   ------------------------------------------- */

.tiny       { font-size: 0.6em; }
.scriptsize { font-size: 0.7em; }
.footnotesize { font-size: 0.8em; }
.small      { font-size: 0.875em; }
.normalsize { font-size: 1em; }
.large      { font-size: 1.2em; }
.Large      { font-size: 1.44em; }
.LARGE      { font-size: 1.728em; }
.huge       { font-size: 2.074em; }
.Huge       { font-size: 2.488em; }


/* -------------------------------------------
   DARK MODE ADJUSTMENTS
   (extends LaTeX.css dark mode)
   ------------------------------------------- */

body.latex-dark .margin-note,
body.latex-dark-auto .margin-note {
  color: #999;
}

body.latex-dark .listing pre,
body.latex-dark-auto .listing pre {
  border-color: #444;
}

body.latex-dark .algorithm,
body.latex-dark-auto .algorithm {
  border-color: #666;
}

body.latex-dark .epigraph,
body.latex-dark-auto .epigraph {
  color: #bbb;
}

@media (prefers-color-scheme: dark) {
  body.latex-dark-auto .margin-note { color: #999; }
  body.latex-dark-auto .listing pre { border-color: #444; }
  body.latex-dark-auto .algorithm { border-color: #666; }
}
```

---

## Quick Start: Copy-Paste Template

Save this as your starting point for any LaTeX-styled page:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Your Title Here</title>

  <!-- LaTeX.css (foundation) -->
  <link rel="stylesheet" href="https://latex.vercel.app/style.css">

  <!-- Extensions (optional) -->
  <link rel="stylesheet" href="latex-extensions.css">

  <!-- MathJax (optional, for equations) -->
  <script>
  MathJax = {
    tex: {
      inlineMath: [['$', '$']],
      displayMath: [['$$', '$$']],
      tags: 'ams'
    }
  };
  </script>
  <script id="MathJax-script" async
    src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js">
  </script>
</head>
<body class="latex-dark-auto text-justify">
  <article class="indent-pars">

    <h1>Your Title Here</h1>
    <p class="author">
      Your Name<br>
      <time datetime="2026-02-24">February 24, 2026</time>
    </p>

    <div class="abstract">
      <h2>Abstract</h2>
      <p>Write your abstract here.</p>
    </div>

    <h2>Introduction</h2>
    <p>Your content here. This first paragraph is not indented.</p>
    <p>This second paragraph is indented, following LaTeX conventions
       for English-language documents.</p>

    <h2>Main Results</h2>

    <div class="theorem">
      State your theorem here.
    </div>

    <div class="proof">
      Write your proof here.
    </div>

    <h2 class="no-number">References</h2>
    <ol class="bibliography">
      <li>Author, A. (Year). <cite>Title</cite>. Publisher.</li>
    </ol>

  </article>
</body>
</html>
```
