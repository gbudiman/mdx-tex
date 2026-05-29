# mdx-tex

Converts between Markdown (MDX) and Textile, for those of you unfortunate enough to have to maintain a legacy system that relies on Textile.

Pure Ruby, no runtime dependencies.

## Installation

Add to your Gemfile:

```ruby
gem 'mdx-tex'
```

```bash
bundle install
```

Or install directly:

```bash
gem install mdx-tex
```

## Usage

### Markdown -> Textile

```ruby
require 'mdx_tex'

MdxTex.to_textile(markdown: '# Hello **world**')
# => "h3. Hello *world*"

# Override options per call
MdxTex.to_textile(markdown: '# Hello', header_level: 'h1')
# => "h1. Hello"

# Or set them globally
MdxTex.configure do |config|
  config.header_level = 'h2'
  config.list_depth = 1
end

# Per-call options take precedence over global config
MdxTex.to_textile(markdown: '- item', list_depth: 2)
```

### Textile -> Markdown

```ruby
MdxTex.to_markdown(textile: 'h3. Hello *world*')
# => "### Hello **world**"
```

Unlike `to_textile`, `to_markdown` takes no options. Heading level maps directly (`h1` -> `#`, `h2` -> `##`, ..., `h6` -> `######`), the list base depth is auto-detected per document, and ordered list numbers are computed from per-depth counters that reset on blank or interrupting lines.

### String Extension

Adds `to_textile` and `to_markdown` directly to `String`. Off by default.

**Any Ruby app:**

```ruby
require 'mdx_tex/core_ext/string'

'# Hello **world**'.to_textile
# => "h3. Hello *world*"

'- item'.to_textile(list_depth: 1)
# => "* item"

'h3. Hello *world*'.to_markdown
# => "### Hello **world**"
```

Or load it through config:

```ruby
MdxTex.configure do |config|
  config.enable_string_extension = true
end
MdxTex.load_string_extension!
```

**Rails** (`config/initializers/mdx_tex.rb`):

```ruby
MdxTex.configure do |config|
  config.enable_string_extension = true
end
```

The Railtie loads this automatically after initialization.

## Supported Syntaxes

### Headers

**Markdown -> Textile** converts all headings (`#` through `######`) to the same Textile tag. The number of `#` doesn't matter; `header_level` controls which tag to use (default: `h3`).

| Markdown | header_level | Textile |
|----------|--------------|---------|
| `# Title` | `h3` (default) | `h3. Title` |
| `## Title` | `h3` (default) | `h3. Title` |
| `###### Title` | `h3` (default) | `h3. Title` |
| `# Title` | `h1` | `h1. Title` |
| `### Title` | `h1` | `h1. Title` |

Requires a space after `#`. `#NoSpace` won't convert. Heading hierarchy is not preserved (`##` and `###` both produce the same tag) — we plan to fix this in a future version.

**Textile -> Markdown** maps the Textile tag directly to the matching number of `#`s.

| Textile | Markdown |
|---------|----------|
| `h1. Title` | `# Title` |
| `h3. Title` | `### Title` |
| `h6. Title` | `###### Title` |

Requires a space after `hN.`. `h3.NoSpace` won't convert.

### Bold

**Markdown -> Textile** turns `**text**` and `__text__` into `*text*`. Multiple spans and mixed delimiters work on the same line.

| Markdown | Textile |
|----------|---------|
| `**hello**` | `*hello*` |
| `__hello__` | `*hello*` |
| `**a** and **b**` | `*a* and *b*` |
| `**a** and __b__` | `*a* and *b*` |

**Textile -> Markdown** turns `*text*` into `**text**`. Whitespace-padded asterisks (`*  text  *`) are not bold per Textile rules and are left unchanged.

| Textile | Markdown |
|---------|----------|
| `*hello*` | `**hello**` |
| `*a* and *b*` | `**a** and **b**` |
| `*  hello  *` | `*  hello  *` |

### Unordered Lists

**Markdown -> Textile** converts `- item` to `* item`. Nesting uses 2-space indentation. `list_depth` controls the base asterisk count (default: `3`).

| Markdown | list_depth | Textile |
|----------|------------|---------|
| `- Item` | 1 | `* Item` |
| `- Item` | 3 | `*** Item` |
| `  - Nested` | 3 | `**** Nested` |
| `    - Deep` | 3 | `***** Deep` |

**Textile -> Markdown** auto-detects the depth-1 base per document (the smallest leading-asterisk run anywhere in the input) and emits Markdown with 2-space indentation per nesting level. This makes the conversion robust to input authored at different base depths.

| Textile (input) | Markdown (output) |
|-----------------|-------------------|
| `* item`<br>`** nested` | `- item`<br>`  - nested` |
| `*** item`<br>`**** nested` | `- item`<br>`  - nested` |
| `*** a`<br>`***** deep` | `- a`<br>`    - deep` |

### Ordered Lists

**Markdown -> Textile** converts `1. item` to `# item`. The actual number is ignored. Nesting uses 2-space indentation.

| Markdown | Textile |
|----------|---------|
| `1. First` | `# First` |
| `99. Any number` | `# Any number` |
| `  1. Nested` | `## Nested` |
| `    1. Deep` | `### Deep` |

**Textile -> Markdown** auto-detects the depth-1 base (smallest leading-`#` run) and emits incrementing numbers per depth. Counters reset on any non-ordered-list line (blank line, plain text, header, unordered item), so each separate list starts at `1.` again.

| Textile (input) | Markdown (output) |
|-----------------|-------------------|
| `# a`<br>`# b`<br>`# c` | `1. a`<br>`2. b`<br>`3. c` |
| `# a`<br>`## x`<br>`## y`<br>`# b` | `1. a`<br>`  1. x`<br>`  2. y`<br>`2. b` |
| `# a`<br>`# b`<br>(blank)<br>`# c` | `1. a`<br>`2. b`<br>(blank)<br>`1. c` |

### Not Supported

The following syntax passes through as-is in both directions (no conversion):

- Italic (`*text*` / `_text_` in Markdown; `_text_` in Textile)
- Strikethrough (`~~text~~` / `-text-`)
- Links (`[text](url)` / `"text":url`)
- Images (`![alt](url)` / `!url!`)
- Inline code (`` `code` ``) and code blocks
- Blockquotes (`>` / `bq.`)
- Tables
- Horizontal rules (`---`)
- Task lists (`- [ ]`, `- [x]`)
- Textile-specific syntax: attributes (`h3{color:red}.`), block modifiers other than `hN.`, footnotes, acronyms

## Configuration

Configuration applies to `to_textile` only. `to_markdown` auto-detects everything from the input and takes no options.

| Option | Type | Valid Values | Default | Description |
|--------|------|-------------|---------|-------------|
| `header_level` | String | `h1`..`h6` | `h3` | Textile heading tag |
| `list_depth` | Integer | Positive integer | `3` | Base asterisk count for unordered lists |

Bad values raise `InvalidHeaderLevelError` or `InvalidListDepthError`.

## Full Example

Markdown input:
```markdown
### **Title**

- item one
- **item two**
  - nested with **bold**

1. **first**
2. second
```

After `MdxTex.to_textile` (default config):
```textile
h3. *Title*

*** item one
*** *item two*
**** nested with *bold*

# *first*
# second
```

After feeding that back through `MdxTex.to_markdown`:
```markdown
### **Title**

- item one
- **item two**
  - nested with **bold**

1. **first**
2. second
```

The round-trip is stable for canonical inputs: headers at the configured `header_level`, bold using `**` (not `__`), unordered lists at depth 1 matching `list_depth`, and ordered list numbers already incrementing per depth.

## Development

```bash
git clone https://github.com/gbudiman/mdx-tex.git
cd mdx-tex
bundle install
```

### Git Hooks

Uses [overcommit](https://github.com/sds/overcommit) for pre-commit RuboCop. After cloning:

```bash
bundle exec overcommit --install
bundle exec overcommit --sign
```

### Tests

```bash
bundle exec rspec
```

### Lint

```bash
bundle exec rubocop
```

## Releasing

```bash
bin/release patch   # 0.1.10 → 0.1.11
bin/release minor   # 0.1.10 → 0.2.0
bin/release major   # 0.1.10 → 1.0.0
```

Runs specs, bumps the version, commits, tags, and pushes. GitHub Actions handles the RubyGems publish.

## License

MIT
