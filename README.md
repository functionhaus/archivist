# Archivist

[![CircleCI](https://circleci.com/gh/functionhaus/archivist.svg?style=svg)](https://circleci.com/gh/functionhaus/archivist)

Archivist is a straightforward blogging utility for generating article content
at compile time from version-controlled article and image files. It is built to
be used in conjunction with the [Arcdown plaintext article parser library](https://github.com/functionhaus/arcdown).

Archivist is inspired by the general approach of Cẩm Huỳnh's great
[Nabo](https://github.com/qcam/nabo) library with some key differences:

* Articles are formatted in `Arcdown` format by default, allowing for more robust articles and article features.

* Content parsing and sorting mechanisms are exposed as anonymous functions, easiliy exposing custom functionality.

* Articles can be organized into nested *topic* directories for better organization. Topics are parsed in a hierarchical structure.

* Use of an "intermediate library pattern" is supported, allowing content and articles to be stored in a dedicated library and separate repository.

* Default attributes are included for both author names and email addresses

* `created_at` and `published_at` timestamps are permitted

* Flexible *tags* can be applied as desired to any article

* Custom content constraints throw warnings during compilation if violated

* Slug uniqueness is enforced by default and triggers compile-time warnings

* Image files can be stored alongside articles, and accessed with helpers

## Installation

The package can be installed by adding `archivist` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:archivist, "~> 0.3"}
  ]
end
```

## Usage

The heart of Archivist is the `Archive` module, which acts as a repository for
exposing query functions for articles, slugs, topics, etc. You can create an
Archive out of any Elixir module by using `Archivist.Archive` like this:

```elixir
defmodule MyApp.Archive
  use Archivist.Archive
end

# this alias is just a nicety, not required
alias MyApp.Archive

Archive.articles()
Archive.topics() # hierarchical topics
Archive.topics_list() # flattened topics and sub-topics
Archive.tags()
Archive.slugs()
Archive.authors()
```

Additionally Archvist exposes helpers for reading paths for articles and
image files:

```elixir
Archive.article_paths()
Archive.image_paths()
```

Archivist 0.3.x and 0.2.x versions expect you to create your article content directory at
`priv/archive/articles` at the root of your elixir library, like this:

`priv/archive/articles/journey_to_the_center_of_the_earth.ad`

If you'd like to customize any of your archive's behavior, you can define any of
the following options when it is used in the target archive directory. The values
shown are the defaults:

```elixir
defmodule MyApp.Archive
  use Archivist.Archive,
    archive_dir: "priv/archive",
    content_dir: "articles",
    content_pattern: "**/*.ad",
    image_dir: "images",
    image_pattern: "**/*.{jpg,gif,png}",
    article_sorter: &(Map.get(&1, :published_at) >= Map.get(&2, :published_at)),
    article_parser: &Arcdown.parse_file(&1),
    content_parser: &Earmark.as_html!(&1),
    slug_warnings: true,
    application: nil,
    valid_tags: nil,
    valid_topics: nil,
    valid_authors: nil
end
```

Archivist will read any files with the `.ad` extension in your content directory
or in any of its subdirectories, and parse the content of those files with the
parser you've selected (Arcdown by default)

If you'd like to store your archive somewhere besides `priv/archive` you can
assign a custom path to your archive like this:

```elixir
defmodule MyApp.Archive
  use Archivist.Archive, archive_dir: "assets/archive",
end
```

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

By default Archivist will parse and return article content as
`Archivist.Article` structs. The parsing output of the above article example
would look like this:

```elixir
%Archivist.Article{
  author: "Julian Blaustein",
  content: "The Day the Earth Stood Still (a.k.a. Farewell to the Master and Journey to the\nWorld) is a 1951 American black-and-white science fiction film from 20th Century\nFox, produced by Julian Blaustein and directed by Robert Wise.\n",
  parsed_content: "<p>The Day the Earth Stood Still (a.k.a. Farewell to the Master and Journey to the\nWorld) is a 1951 American black-and-white science fiction film from 20th Century\nFox, produced by Julian Blaustein and directed by Robert Wise.</p>\n",
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
## Intermediate Library Pattern

While it's completely acceptable use Archivist.Archive within the same
application in which the content archive is located, sites with lots of content
and publishers who commit changes frequently will quickly find the git
history for their application littered with content-related commits that have
nothing to do with the broader functionality of the application itself.

To remedy this issue, Archivist permits and encourages the use of an
intermediate library to house the content archive (`myapp_blog` for example),
and then to include that intermediate library in the target application where
the content is being used and displayed.

This approach requires you generate a new mix library with `mix new myapp_blog`,
and then to publish that repository so that it's available to other Elixir and
Erlang applications, via hex.pm or hex.pm organizations for example.

The preferred way to implement this approach is to include `archivist` as a
dependency in your intermediate library (rather than in your application), and
then to create a new Archive in your intermediate library like this:

```elixir
defmodule MyappBlog.Archive do
  use Archivist.Archive,
    application: :myapp_blog,
    archive_dir: "archive"
end
```

Note that this approach requires you to add the name of your otp application in
the `application` flag when your archive is defined. Also note that `archive_dir`
is compressed to just `archive` instead of `priv/archive` since this approach
automatically assumes that content will be stored in the `priv` directory of the
otp app indicated by the `application` option.

Here is an example of an excerpt from the mixfile of an intermediate library:

```elixir
  defp deps do
    [
      {:archivist, "~> 0.3"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
     files: ["lib", "priv", "mix.exs", "README.md"],
     organization: "my_hex_org"
    ]
  end
```

Requiring the priv dir here is essential to ensuring that the content archive is
packaged with the hex release, and is then made available for the target
application.

Setting the organization here scopes the published package to a hex
organization, thus ensuring that it remains private.

Then in the application where your content is being used, be sure to include the
intermediate library as a dependency:

```elixir
defp deps do
  [
    ...
    {:myapp_blog, "~> 0.1", organization: "my_hex_org"}
  ]
end
```

And then you should be able to use your content directly in your application:

```elixir
MyappBlog.Archive.articles()
MyappBlog.Archive.topics()
```

## Parsed Content Constraints

As of Archivist version `0.2.6` archives can receive flags for lists of
`valid_topics` and `valid_tags`. Version `0.2.9` added support for
`valid_authors` constraints. Here are some examples of constraints:

```elixir
defmodule Myapp.Archive do
  use Archivist,
    valid_topics: [
      "Action",
      "Classic",
      "Crime",
      "Fiction",
      "Films",
      "Sci-Fi"
    ],
    valid_tags: [
      :action,
      :adventure,
      :aliens,
      :crime,
      :horror,
      :literature,
      :modern_classic,
      :sci_fi,
      :thrillers
    ],
    valid_authors: [
      "Jules Verne",
      "Julian Blaustein",
      "Michael Mann"
    ]
end
```

Adding articles with tags, topics or authors that don't conform to these lists,
or using a topic directory structure that doesn't conform to these lists will
throw warnings at compile time, like this:

```elixir
warning: Archivist Archive contains invalid topics: Action, Classic
  (archivist) lib/archivist/parsers/article_parser.ex:77: Archivist.ArticleParser.warn_invalid/3

warning: Archivist Archive contains invalid tags: action, adventure
  (archivist) lib/archivist/parsers/article_parser.ex:77: Archivist.ArticleParser.warn_invalid/3

warning: Archivist Archive contains invalid authors: Ernest Hemingway
  (archivist) lib/archivist/parsers/article_parser.ex:77: Archivist.ArticleParser.warn_invalid/3
```

Compilation will not cease, however, simply because these constraints are
being violated.

Please note that only exact topic and author matches are accounted for here,
so`"Sci-Fi"` will not be considered equivalent to `"SciFi"` and will throw a
warning. Similarly, "J.D. Salinger" will not be considered to be the same
author as "JD Salinger" by the article parser.

If you do not want warnings for tags, topics or authors during compilation
simply don't declare any values for `valid_topics`, `valid_tags`, or
`valid_authors` depending on your desired outcomes, and they'll be ignored.

Also note that enforcement of valid topics currently is only compared to the
flattened list of topics and sub-topics. There is no functionality in place
at the moment for constraining specific topic hierarchies.

It should additionally be noted that the `slug_warnings` filter is on by
default, meaning that the parser will throw warnings if duplicate slugs are
found across articles in your content archive. This can be turned off by
setting `slug_warnings: false` when you declare your archive, like this:


```elixir
defmodule Myapp.Archive do
  use Archivist, slug_warnings: false
end
```

## Mounting Images with Plug

If you choose to store images with your archive, it's probably most useful to
have that content mounted as a static assets path somewhere where the content
can be digested with Webpack or whichever assets manager you're using.

For systems built with Plug (including Phoenix), it's easy enough to mount the
images path with `Plug.Static` at the path of your choice. Simply call the name
of the otp app where your content is stored along with the path to the images:

```elixir
plug Plug.Static,
  at: "/blog/images/",
  from: {:myapp_blog, "priv/archive/images"}
```

Note that for applications that employed the Intermediate Library Pattern, the
flags for `Plug.Static` will look like the example above. For instances where
Archivist is being used directly in the target application, the name of the
current application should be used here, like this:

```elixir
plug Plug.Static,
  at: "/blog/images/",
  from: {:myapp, "priv/archive/images"}
```

For use within Phoenix in particular, your plug declaration would likely go in
the `MyappWeb.Endpoint` module, like this:

```elixir
defmodule MyappWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :myapp

  # app name here will be :myapp or :myapp_blog depending on which otp app
  # contains the content archive
  plug Plug.Static,
    at: "/blog/images/",
    from: {:myapp_blog, "priv/archive/images"}
```

## Development Notes

Please find additional information about known issues and planned features for
Archivist in the [issues tracker](https://github.com/functionhaus/archivist/issues).

## Todo

Issues and Todo enhancements are managed at the official
[Archivist issues tracker](https://github.com/functionhaus/archivist/issues) on GitHub.

## Availability

Source code is available at the official
[Archivist repository](https://github.com/functionhaus/arcdown)
on the [FunctionHaus GitHub Organization](https://github.com/functionhaus)

## License

Archivist source code is released under Apache 2 License.
Check LICENSE file for more information.

&copy; 2017 FunctionHaus, LLC
