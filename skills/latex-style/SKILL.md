---
name: latex-style
description: Style websites to look and feel like LaTeX documents. Use when the user wants academic paper aesthetics, Computer Modern / Latin Modern typography, theorem environments, numbered sections, or that distinctive scholarly typographic rhythm on a web page. NOT for converting HTML to actual LaTeX — this is about visual style only.
---

# LaTeX Style Skill

Make web pages look and feel like LaTeX-typeset documents. This is about the **aesthetic** — the fonts, the spacing, the rhythm, the theorem boxes, the numbered sections — rendered as HTML + CSS for the browser.

## Core Philosophy

1. **Faithful to the Source** — LaTeX's beauty comes from Knuth's obsessive attention to typographic detail. Respect it. Don't approximate — replicate.
2. **Semantic HTML** — LaTeX is a semantic language (`\section`, `\theorem`, `\proof`). Map these to semantic HTML elements and CSS classes. No divs-with-inline-styles hacks.
3. **Progressive Enhancement** — Start with LaTeX.css as foundation, enhance with custom extensions. Don't reinvent what already works.
4. **Modern Stack Compatible** — Works with React, Vite, Tailwind, plain HTML. The LaTeX aesthetic shouldn't require abandoning your framework.
5. **Typography First** — If the fonts and spacing aren't right, nothing else matters.

---

## Foundation: LaTeX.css

Use [LaTeX.css](https://latex.vercel.app/) (MIT, by vincentdoerig) as the base layer. It provides:

- Latin Modern / Libertinus font families (web fonts)
- Theorem, definition, lemma, proof environments
- Author and abstract blocks
- Sidenotes (alternative to footnotes)
- Booktabs-style table borders
- Dark mode support
- MathJax integration
- Automatic section numbering via CSS counters
- Paragraph indentation (LaTeX-style first-line indent)

### Installation

**CDN (simplest):**
```html
<link rel="stylesheet" href="https://latex.vercel.app/style.css">
```

**npm:**
```bash
npm install latex.css
```
```js
import 'latex.css';
```

**Self-hosted (for customization):**
Download `style.css` from https://github.com/vincentdoerig/latex-css and include locally.

---

## Typography Rules

These rules define what makes something *feel* like LaTeX vs. just "a serif font."

### Fonts

**Primary choice: Latin Modern** (the modern successor to Computer Modern)
```css
body {
  font-family: 'Latin Modern Roman', 'Computer Modern Serif',
               'STIX Two Text', 'Georgia', serif;
}
```

**Web font source:**
```html
<!-- Latin Modern via CDN -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/aaaakshat/cm-web-fonts@latest/fonts.css">
```

This provides:
- `Computer Modern Serif` — body text
- `Computer Modern Sans` — sans-serif (used sparingly in LaTeX)
- `Computer Modern Typewriter` — monospace / code

**Alternative: Libertinus** (more readable on screen, still scholarly)
```css
body {
  font-family: 'Libertinus Serif', 'Latin Modern Roman', Georgia, serif;
}
```

LaTeX.css includes both. Toggle with class `libertinus` on `<body>`.

### Font Sizing

LaTeX default is 10pt body with a ~1.2x scale. On the web, map this to:

```css
:root {
  --base-size: 1rem;         /* ~16px, maps to LaTeX 10pt at screen distance */
  --small-size: 0.875rem;    /* \small */
  --footnote-size: 0.8rem;   /* \footnotesize */
  --script-size: 0.7rem;     /* \scriptsize */
  --tiny-size: 0.6rem;       /* \tiny */
  --large-size: 1.2rem;      /* \large */
  --Large-size: 1.44rem;     /* \Large */
  --LARGE-size: 1.728rem;    /* \LARGE */
  --huge-size: 2.074rem;     /* \huge */
  --Huge-size: 2.488rem;     /* \Huge */
}
```

### Line Height & Spacing

LaTeX uses ~1.2 line height (tight by web standards, but correct for the aesthetic):

```css
body {
  line-height: 1.2;          /* LaTeX default baselineskip/fontsize */
}

p {
  margin-top: 0;
  margin-bottom: 0;
}

/* LaTeX-style paragraph separation: indent, not spacing */
article.indent-pars p + p {
  text-indent: 1.5em;
}

/* First paragraph after heading: no indent (English convention) */
article.indent-pars h1 + p,
article.indent-pars h2 + p,
article.indent-pars h3 + p,
article.indent-pars h4 + p {
  text-indent: 0;
}
```

### Text Justification & Hyphenation

LaTeX justifies everything and hyphenates aggressively. On the web:

```css
body.text-justify {
  text-align: justify;
  hyphens: auto;
  -webkit-hyphens: auto;
  hyphenate-limit-chars: 6 3 2;  /* min word length, before break, after break */
  hyphenate-limit-lines: 2;      /* max consecutive hyphenated lines */
  hyphenate-limit-zone: 8%;
}

/* Prevent hyphenation of specific elements */
code, kbd, samp, var, .no-hyphen {
  hyphens: none;
}
```

### Page Width

LaTeX `article` class uses ~4.5in text width (~72 characters per line). Map this:

```css
body {
  max-width: 80ch;    /* ~72-80 characters — the LaTeX sweet spot */
  margin: 0 auto;
  padding: 0 2rem;
}
```

For Tufte-style sidenotes, wider:
```css
body.with-sidenotes {
  max-width: 100ch;
  padding-left: 2rem;
  padding-right: 25ch;  /* room for sidenotes */
}
```

---

## Document Structure

### Minimal LaTeX-Style Page

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document Title</title>
  <link rel="stylesheet" href="https://latex.vercel.app/style.css">
  <!-- MathJax (optional, for equations) -->
  <script id="MathJax-script" async
    src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js">
  </script>
</head>
<body class="text-justify">
  <article class="indent-pars">
    <h1>Document Title</h1>
    <p class="author">
      Author Name<br>
      <time datetime="2026-02-24">February 24, 2026</time>
    </p>

    <div class="abstract">
      <h2>Abstract</h2>
      <p>A brief summary of the document content...</p>
    </div>

    <nav role="navigation" class="toc">
      <h2>Contents</h2>
      <ol>
        <li><a href="#introduction">Introduction</a></li>
        <li><a href="#methods">Methods</a></li>
        <li><a href="#results">Results</a></li>
        <li><a href="#conclusion">Conclusion</a></li>
      </ol>
    </nav>

    <h2 id="introduction">Introduction</h2>
    <p>First paragraph after a heading is not indented...</p>
    <p>Subsequent paragraphs are indented. This mimics LaTeX's
       default behavior for English-language documents.</p>

    <h2 id="methods">Methods</h2>
    <p>...</p>

    <h2 id="results">Results</h2>

    <div class="theorem">
      The sum of two even numbers is always even.
    </div>

    <div class="proof">
      Let $a = 2m$ and $b = 2n$ for integers $m, n$.
      Then $a + b = 2m + 2n = 2(m + n)$, which is even.
    </div>

    <h2 id="conclusion">Conclusion</h2>
    <p>...</p>

    <h2>References</h2>
    <ol class="bibliography">
      <li id="ref-1">Knuth, D. E. (1984). <cite>The TeXbook</cite>. Addison-Wesley.</li>
      <li id="ref-2">Lamport, L. (1994). <cite>LaTeX: A Document Preparation System</cite>.</li>
    </ol>
  </article>
</body>
</html>
```

### Section Numbering

LaTeX.css provides automatic numbering via CSS counters. Sections are numbered in nested format (1, 1.1, 1.1.1):

```css
/* Already included in LaTeX.css, but for reference: */
body {
  counter-reset: section;
}

h2 {
  counter-reset: subsection;
  counter-increment: section;
}

h2::before {
  content: counter(section) "\2001";  /* "1 " */
}

h3 {
  counter-increment: subsection;
}

h3::before {
  content: counter(section) "." counter(subsection) "\2001";  /* "1.1 " */
}
```

To disable numbering for a specific heading, add class `no-number`:
```html
<h2 class="no-number">Acknowledgments</h2>
```

---

## Environments

### Theorem-Like Environments

LaTeX.css supports four built-in environment types:

```html
<div class="theorem">Content of theorem...</div>
<div class="lemma">Content of lemma...</div>
<div class="definition">Content of definition...</div>
<div class="proof">Content of proof...</div>
```

These auto-number and add labels ("Theorem 1.", "Lemma 1.", etc.).

### Custom Environments (Beyond LaTeX.css)

For environments not in LaTeX.css, extend with custom CSS:

```css
/* Corollary environment */
.corollary {
  font-style: italic;
  display: block;
  margin: 1em 0;
  counter-increment: corollary;
}

.corollary::before {
  content: "Corollary " counter(corollary) ". ";
  font-weight: bold;
  font-style: normal;
}

/* Remark environment */
.remark {
  display: block;
  margin: 1em 0;
  counter-increment: remark;
}

.remark::before {
  content: "Remark " counter(remark) ". ";
  font-style: italic;
}

/* Example environment */
.example {
  display: block;
  margin: 1em 0;
  counter-increment: example;
}

.example::before {
  content: "Example " counter(example) ". ";
  font-weight: bold;
}

/* Proposition */
.proposition {
  font-style: italic;
  display: block;
  margin: 1em 0;
  counter-increment: proposition;
}

.proposition::before {
  content: "Proposition " counter(proposition) ". ";
  font-weight: bold;
  font-style: normal;
}

/* Conjecture */
.conjecture {
  font-style: italic;
  display: block;
  margin: 1em 0;
  counter-increment: conjecture;
}

.conjecture::before {
  content: "Conjecture " counter(conjecture) ". ";
  font-weight: bold;
  font-style: normal;
}

/* Axiom */
.axiom {
  font-style: italic;
  display: block;
  margin: 1em 0;
  counter-increment: axiom;
}

.axiom::before {
  content: "Axiom " counter(axiom) ". ";
  font-weight: bold;
  font-style: normal;
}

/* Reset counters at document level */
article {
  counter-reset: corollary remark example proposition conjecture axiom;
}
```

### Named Theorems

For named theorems (e.g., "Theorem (Cantor's Diagonal Argument)"), use a data attribute:

```html
<div class="theorem" data-name="Cantor's Diagonal Argument">
  The real numbers are uncountable.
</div>
```

```css
.theorem[data-name]::before {
  content: "Theorem " counter(theorem) " (" attr(data-name) "). ";
}
```

### Algorithm / Pseudocode

```html
<figure class="algorithm">
  <figcaption>Algorithm 1: Binary Search</figcaption>
  <pre class="pseudocode">
<b>function</b> BinarySearch(A, target)
    lo ← 0
    hi ← length(A) − 1
    <b>while</b> lo ≤ hi <b>do</b>
        mid ← ⌊(lo + hi) / 2⌋
        <b>if</b> A[mid] = target <b>then</b>
            <b>return</b> mid
        <b>else if</b> A[mid] < target <b>then</b>
            lo ← mid + 1
        <b>else</b>
            hi ← mid − 1
    <b>return</b> −1
  </pre>
</figure>
```

```css
.algorithm {
  border: 1px solid currentColor;
  padding: 1em 1.5em;
  margin: 1.5em 0;
  counter-increment: algorithm;
}

.algorithm > figcaption {
  font-weight: bold;
  margin-bottom: 0.75em;
  text-align: left;
}

.pseudocode {
  font-family: 'Computer Modern Typewriter', 'Courier New', monospace;
  font-size: 0.9em;
  line-height: 1.5;
  white-space: pre;
  overflow-x: auto;
}
```

---

## Tables

LaTeX tables (with booktabs) use horizontal rules only — no vertical lines. This is the single most recognizable table style in academic publishing.

```html
<table class="borders-custom">
  <caption>Table 1: Experimental results across three conditions.</caption>
  <thead>
    <tr class="border-bottom-thick">
      <th>Condition</th>
      <th>Mean</th>
      <th>Std. Dev.</th>
      <th>$p$-value</th>
    </tr>
  </thead>
  <tbody>
    <tr class="border-bottom-thin">
      <td>Control</td>
      <td>3.42</td>
      <td>0.87</td>
      <td>—</td>
    </tr>
    <tr class="border-bottom-thin">
      <td>Treatment A</td>
      <td>5.61</td>
      <td>1.23</td>
      <td>0.003</td>
    </tr>
    <tr class="border-bottom-thick">
      <td>Treatment B</td>
      <td>4.98</td>
      <td>0.95</td>
      <td>0.021</td>
    </tr>
  </tbody>
</table>
```

**Key rules for LaTeX-style tables:**
- NO vertical borders, ever
- Thick rules at top and bottom of table
- Thin rule below header row
- Optional thin rules between logical groups
- Caption ABOVE the table (not below) — this is the LaTeX convention
- Left-align text columns, right-align numeric columns

---

## Figures & Captions

LaTeX places figure captions below the figure, centered, with "Figure N:" prefix:

```html
<figure>
  <img src="chart.png" alt="Descriptive alt text">
  <figcaption>
    Distribution of token prices across the observed period.
    Error bars represent 95% confidence intervals.
  </figcaption>
</figure>
```

```css
figure {
  margin: 2em 0;
  text-align: center;
  counter-increment: figure;
}

figcaption {
  font-size: var(--small-size);
  text-align: center;
  margin-top: 0.5em;
}

figcaption::before {
  content: "Figure " counter(figure) ": ";
  font-weight: bold;
}

/* Reset in article */
article {
  counter-reset: figure;
}
```

---

## Code Listings

LaTeX code listings have a distinct look — framed, with caption, monospaced:

```html
<figure class="listing">
  <figcaption>Listing 1: Solidity deposit function</figcaption>
  <pre><code class="language-solidity">function deposit(uint256 amount) external {
    token.transferFrom(msg.sender, address(this), amount);
    balances[msg.sender] += amount;
    emit Deposited(msg.sender, amount);
}</code></pre>
</figure>
```

```css
.listing {
  counter-increment: listing;
  margin: 1.5em 0;
}

.listing > figcaption {
  font-size: var(--small-size);
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
}

.listing code {
  font-family: 'Computer Modern Typewriter', 'Fira Code', 'Consolas', monospace;
}
```

For syntax highlighting, use Prism.js with a neutral theme that doesn't clash with the LaTeX aesthetic.

---

## Mathematics

Use MathJax or KaTeX for rendering. MathJax is more complete; KaTeX is faster.

### MathJax Setup

```html
<script>
MathJax = {
  tex: {
    inlineMath: [['$', '$'], ['\\(', '\\)']],
    displayMath: [['$$', '$$'], ['\\[', '\\]']],
    tags: 'ams',       /* equation numbering */
    macros: {
      /* Define custom macros here */
      R: '\\mathbb{R}',
      N: '\\mathbb{N}',
      Z: '\\mathbb{Z}',
      norm: ['\\left\\|#1\\right\\|', 1],
    }
  }
};
</script>
<script id="MathJax-script" async
  src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js">
</script>
```

### KaTeX Setup (faster)

```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.css">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.js"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/contrib/auto-render.min.js"
  onload="renderMathInElement(document.body);">
</script>
```

### Equation Numbering

```html
<!-- Numbered equation -->
$$
E = mc^2 \tag{1}
$$

<!-- Aligned equations -->
$$
\begin{align}
  a &= b + c \tag{2} \\
  d &= e \cdot f \tag{3}
\end{align}
$$
```

---

## Sidenotes & Footnotes

### Sidenotes (Tufte-style, LaTeX.css built-in)

Sidenotes appear in the margin on wide screens, inline on mobile:

```html
<p>
  The survival accumulator tracks proportional loss.
  <label for="sn-1" class="sidenote-toggle sidenote-number"></label>
  <input type="checkbox" id="sn-1" class="sidenote-toggle">
  <span class="sidenote">
    This is analogous to Alchemix V3's earmark mechanism,
    where the Transmuter claims debt proportionally.
  </span>
</p>
```

### Traditional Footnotes

For classic LaTeX bottom-of-page footnotes:

```html
<p>
  The protocol uses a novel accounting mechanism.<sup><a href="#fn1" id="fnref1">1</a></sup>
</p>

<!-- At bottom of document -->
<section class="footnotes" role="doc-endnotes">
  <hr>
  <ol>
    <li id="fn1">
      <p>See Appendix A for the full derivation.
        <a href="#fnref1" class="footnote-back">↩</a></p>
    </li>
  </ol>
</section>
```

---

## Bibliography / References

LaTeX bibliographies have a specific style. Replicate with:

```html
<h2 class="no-number">References</h2>
<ol class="bibliography">
  <li id="ref-knuth84">
    Knuth, D. E. (1984).
    <cite>The TeXbook</cite>.
    Addison-Wesley Professional.
  </li>
  <li id="ref-lamport94">
    Lamport, L. (1994).
    <cite>LaTeX: A Document Preparation System</cite>.
    Addison-Wesley. 2nd edition.
  </li>
</ol>
```

```css
.bibliography {
  padding-left: 2em;
}

.bibliography li {
  margin-bottom: 0.5em;
  font-size: var(--small-size);
  line-height: 1.4;
}

.bibliography cite {
  font-style: italic;
}
```

In-text citation:
```html
<p>As shown by Knuth [<a href="#ref-knuth84">1</a>], ...</p>
```

---

## Integration with Modern Frameworks

### React + Vite

```tsx
// App.tsx
import 'latex.css';
import './latex-extensions.css';  // your custom environments

function Paper() {
  return (
    <article className="indent-pars">
      <h1>Self-Repaying Subscriptions via Proportional Accounting</h1>
      <p className="author">
        Anonymous<br />
        <time>February 2026</time>
      </p>

      <div className="abstract">
        <h2>Abstract</h2>
        <p>We present AlchemySub, a protocol for...</p>
      </div>

      <h2>Introduction</h2>
      <p>...</p>

      <div className="theorem">
        For any deposit $d$ and loss ratio $\ell \in [0,1]$,
        the refund amount is exactly $d \cdot \ell$.
      </div>

      <div className="proof">
        By the properties of the Q128 fixed-point accumulator...
      </div>
    </article>
  );
}
```

### With Tailwind CSS

LaTeX.css and Tailwind can coexist. LaTeX.css targets semantic elements; Tailwind adds utility where needed.

```html
<body class="text-justify">
  <article class="indent-pars mx-auto max-w-prose px-8">
    <!-- LaTeX.css handles typography, Tailwind handles layout -->
  </article>
</body>
```

To avoid conflicts, load LaTeX.css BEFORE Tailwind, and use Tailwind's `@layer` to set specificity:

```css
/* main.css */
@import 'latex.css';
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### With Markdown (MDX, Astro, etc.)

LaTeX.css is almost classless — standard Markdown-generated HTML looks correct automatically. Just wrap in `<article>` and add the stylesheet.

For environments, use MDX components:

```mdx
import { Theorem, Proof, Definition } from './LaTeXEnvironments';

<Theorem name="Main Result">
  The protocol is safe under all loss scenarios.
</Theorem>

<Proof>
  By induction on the number of epochs...
</Proof>
```

---

## Dark Mode

LaTeX.css includes dark mode:

```html
<!-- Auto (follows system preference) -->
<body class="latex-dark-auto text-justify">

<!-- Forced dark -->
<body class="latex-dark text-justify">
```

For a toggle button:
```js
document.getElementById('dark-toggle').addEventListener('click', () => {
  document.body.classList.toggle('latex-dark');
});
```

Dark mode inverts to a warm dark background (not pure black) with cream-tinted text — faithful to how a LaTeX PDF looks on a dark-mode PDF viewer.

---

## Extended Styles (Beyond LaTeX.css)

### Epigraph

```html
<blockquote class="epigraph">
  <p>In the beginning was the command line.</p>
  <footer>— Neal Stephenson</footer>
</blockquote>
```

```css
.epigraph {
  margin: 2em 0;
  padding-left: 2em;
  max-width: 60%;
  margin-left: auto;
  font-style: italic;
}

.epigraph footer {
  font-style: normal;
  text-align: right;
  margin-top: 0.25em;
  font-size: var(--small-size);
}
```

### Title Page (Full Page)

```html
<header class="title-page">
  <h1>AlchemiQ: Rate-Bucketed Lending<br>via Proportional Accounting</h1>
  <p class="author">
    Scoopy Trooples<sup>1</sup><br>
    <small><sup>1</sup>Alchemix Finance</small>
  </p>
  <p class="date">February 2026</p>
  <p class="subtitle">Working Paper — Draft v0.1</p>
</header>
```

```css
.title-page {
  min-height: 80vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  padding: 4rem 2rem;
}

.title-page h1 {
  font-size: var(--Huge-size);
  line-height: 1.2;
  margin-bottom: 2rem;
}

.title-page .subtitle {
  font-style: italic;
  color: #666;
  margin-top: 1em;
}
```

### Appendix Separator

```html
<hr class="appendix-rule">
<h2 class="appendix-heading">Appendix A: Derivations</h2>
```

```css
.appendix-rule {
  margin: 3em 0 2em;
  border: none;
  border-top: 1px solid currentColor;
}

/* Reset section numbering to A, B, C for appendices */
.appendix-heading {
  counter-reset: subsection;
}
```

### Margin Notes (Tufte-style)

Beyond sidenotes, for persistent margin annotations:

```css
.margin-note {
  float: right;
  clear: right;
  margin-right: -25ch;
  width: 20ch;
  font-size: var(--small-size);
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
```

---

## LaTeX Document Classes as Variants

### article (default)

The standard look. Single column, numbered sections, abstract.

### report

Adds chapter-level headings, table of contents:

```css
body.latex-report h1 {
  font-size: var(--Huge-size);
  text-align: center;
  margin: 3rem 0 2rem;
  page-break-before: always;
}
```

### book

Two-column table of contents, part/chapter/section hierarchy.

### beamer (presentations)

For slide-like pages — combine with the `frontend-slides` skill, using Paper & Ink or Swiss Modern preset with Latin Modern fonts.

### letter

Formal letter layout with sender/recipient blocks:

```html
<article class="latex-letter">
  <header class="letter-sender">
    <p>Alchemix Finance<br>The Internet</p>
    <p><time>February 24, 2026</time></p>
  </header>
  <div class="letter-recipient">
    <p>DeFi Community<br>Everywhere</p>
  </div>
  <p class="letter-opening">Dear Community,</p>
  <p>We are pleased to announce...</p>
  <p class="letter-closing">Sincerely,<br>Scoopy Trooples</p>
</article>
```

---

## Checklist: Does It Look Like LaTeX?

Before declaring a page "LaTeX-styled," verify:

- [ ] **Font** — Latin Modern or Libertinus is loading (check devtools network tab)
- [ ] **Line height** — ~1.2, not the web-standard 1.5+
- [ ] **Justification** — Text is justified with proper hyphenation
- [ ] **Paragraph indentation** — First line indented (not spacing between paragraphs)
- [ ] **First paragraph rule** — First paragraph after a heading is NOT indented
- [ ] **Max width** — Body text is ~80ch wide (not full-bleed)
- [ ] **Section numbering** — Sections numbered "1", "1.1", "1.1.1"
- [ ] **Theorem environments** — Numbered, italicized body, bold label
- [ ] **Proof ending** — QED tombstone (∎) at end of proofs
- [ ] **Tables** — Horizontal rules only (no vertical borders)
- [ ] **Figure captions** — Below figure, "Figure N:" prefix
- [ ] **Table captions** — Above table, "Table N:" prefix
- [ ] **Bibliography** — Numbered list with proper citation formatting
- [ ] **Math rendering** — MathJax or KaTeX producing proper mathematical notation
- [ ] **Monospace** — Code uses Computer Modern Typewriter, not a programming font

---

## Anti-Patterns (What NOT to Do)

- **Don't use Georgia and call it LaTeX.** The whole point is Computer Modern / Latin Modern. Georgia is a fine font; it's just not LaTeX.
- **Don't use line spacing > 1.3.** LaTeX is tight. Web defaults (1.5-1.6) look wrong.
- **Don't separate paragraphs with blank lines.** Use indentation. Blank line spacing is the HTML convention, not LaTeX.
- **Don't add vertical table borders.** LaTeX + booktabs = horizontal rules only.
- **Don't center body text.** Left-aligned or justified, never centered paragraphs.
- **Don't use colored boxes for theorems.** LaTeX theorem environments don't have backgrounds — they're typographic, not visual.
- **Don't put captions below tables.** LaTeX convention: captions above tables, below figures.
- **Don't skip section numbering.** In LaTeX, everything is numbered by default. Unnumbered sections are the exception (marked with `*`).
