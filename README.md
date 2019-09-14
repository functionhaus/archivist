# archivist

Archivist is a straightforward blogging utility for generating article content
at compile time from version-controlled markdown files. It is built to
be used in conjunction with the [Arcdown plaintext article parser library](https://github.com/functionhaus/arcdown).

Archivist is inspired by the general approach of Cẩm Huỳnh's great
[Nabo](https://github.com/qcam/nabo) library with some key differences.

Archivist uses `Arcdown` format by default, allowing for more robust articles
features, such as:

* Archivist is an *opinionated* piece of software, meaning it makes decisions
about how your content should be formatted (Markdown) and parsed (Earmark).

* Archivist allows articles to be organized into nested *topic* directories for
better organization. Topic directories do not currently hold any semantic
meaning, but in the future may be used to optionally infer topic assignment for
articles within those directories.

* Archivist doesn't bother parsing your article summary as markdown because
it's usually only a sentence or two, and you can do that on your own.

* Archivist adds default attributes for author names and email addresses, as
well as sorting content by author.

* Archivist allows you to set a `created_at` and `published_at` timestamps to
give you greater control over content organization.

* Archivist allows you to *tag* your articles however you'd like. Later versions
will allow the user to set compile-time contstraints for tags and topics to
guarantee that only approved tags and topics are used.

## Installation

The package can be installed by adding `archivist` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:archivist, "~> 0.0"}
  ]
end
```

# Usage

The heart of Archivist is the `Archive` module, which acts as a repository for
exposing query functions for articles, slugs, topics, etc. You can create an
Archive out of any Elixir module by using `Archivist.Archive` like this:

```elixir
defmodule MyApp.Archive
  use Archivist.Archive
end

# the alias is just a nicety here and isn't required by any means
alias MyApp.Archive

Archive.articles()
Archive.topics()
Archive.tags()
Archive.slugs()
Archive.authors()
```

Create your article content directory at `priv/articles` at the root of
your elixir library.

`priv/articles/journey_to_the_center_of_the_earth.ad`

Archivist will read any files with the `.ad` extension in your content directory
or in any of its subdirectories, and parse the content of those files with the
parser you've selected (Arcdown by default)

If you'd like to store your articles somewhere besides `priv/articles` you can
assign a custom path to your archive

## Arcdown

Arcdown supports the following features for articles:

* Article Content
* Article Summary
* Topics
* Sub-Topics
* Tags
* Published Datetime
* Creation Datetime
* Author Name
* Author Email
* Article Slug

Here is an example article written in *Arcdown (.ad)* format:

```
The Day the Earth Stood Still <the-day-the-earth-stood-still>
by Julian Blaustein <julian@blaustein.com>

Filed under: Films > Sci-Fi > Classic

Created @ 10:24pm on 1/20/2019
Published @ 10:20pm on 1/20/2019

* Sci-Fi
* Horror
* Thrillers
* Aliens

Summary:
A sci-fi classic about a flying saucer landing in Washington, D.C.

---

The Day the Earth Stood Still (a.k.a. Farewell to the Master and Journey to the
World) is a 1951 American black-and-white science fiction film from 20th Century
Fox, produced by Julian Blaustein and directed by Robert Wise.
```

At the moment articles will be parsed and returned as `Arcdown.Article` structs.
The parsing output of the above article example would be this:

```elixir
%Arcdown.Article{
  author: "Julian Blaustein",
  content: "The Day the Earth Stood Still (a.k.a. Farewell to the Master and Journey to the\nWorld) is a 1951 American black-and-white science fiction film from 20th Century\nFox, produced by Julian Blaustein and directed by Robert Wise.\n",
  created_at: #DateTime<2019-01-20 22:24:00Z>,
  email: "julian@blaustein.com",
  published_at: #DateTime<2019-04-02 04:30:00Z>,
  slug: "the-day-the-earth-stood-still",
  summary: "A sci-fi classic about a flying saucer landing in Washington, D.C.",
  tags: [:sci_fi, :horror, :thrillers, :aliens],
  title: "The Day the Earth Stood Still",
  topics: ["Films", "Sci-Fi", "Classic"]
}
```

# Todo

Issues and Todo enhancements are managed at the official
[Archivist issues tracker](https://github.com/functionhaus/archivist/issues) on GitHub.

## Availability

Source code is available at the official
[Archivist repository](https://github.com/functionhaus/arcdown)
on the [FunctionHaus GitHub Organization](https://github.com/functionhaus)

## License

Archivist source code is released under Apache 2 License.
Check LICENSE file for more information. &copy; 2017 FunctionHaus, LLC
