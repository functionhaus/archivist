# archivist

Archivist is a straightforward blogging utility for generating article content
at compile time from version-controlled markdown files. It is built to
be used in conjunction with the [Arcdown plaintext article parser library](https://github.com/functionhaus/arcdown).

Archivist is inspired by the general approach of Cẩm Huỳnh's great
[Nabo](https://github.com/qcam/nabo) library with some key differences:

* Archivist is an *opinionated* piece of software, meaning it makes decisions
about how your content should be formatted (Markdown) and parsed (Earmark).

* Archivist allows articles to be organized into *topic* directories. Articles
within each directory will be organized by the topic under which they're stored.

* Archivist doesn't bother parsing your article summary as markdown because
it's usually only a sentence or two, and you can do that on your own.

* Archivist adds default attributes for author names and email addresses, as
well as sorting content by author.

* Archivist allows you to set a `created_at` and `published_at` timestamps to
give you greater control over content organization.

* Archivist allows you to *tag* your articles however you'd like. It can also
enforce a constrained set of tags at compile-time if desired.

* Archivist stores well-worn paths for content usage in module attributes,
increasing speed and reducing require runtime computation.

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

Create your articles and topics directories at `priv/articles` at the root of
your elixir library. For example:

`priv/articles/journey_to_the_center_of_the_earth.ad`

# Todo

The following list of forthcoming features are either in progress or slated for
development:

* Throw compile-time errors for duplicate slugs
* Throw compile-time errors for improperly formatted content
* Add support for using a set of articles written as a series
* Add generator tasks for creating pre-structured templates for Arcdown files
* Generate uuid values for arcdown content
* Add `series_id` uuid references for articles included in series

## Availability

This library is currently published at for use with the public hex.pm
repository at https://hex.pm/packages/archivist.

Source code is available at the [FunctionHaus Github Organization](
https://github.com/functionhaus) at
https://github.com/functionhaus/archivist.


## License

archivist source code is released under Apache 2 License.
Check LICENSE file for more information.
