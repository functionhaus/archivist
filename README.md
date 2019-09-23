# Archivist

[![CircleCI](https://circleci.com/gh/functionhaus/archivist.svg?style=svg)](https://circleci.com/gh/functionhaus/archivist)

Archivist is a straightforward blogging utility for generating article content
at compile time from version-controlled article and image files. It is built to
be used in conjunction with the [Arcdown plaintext article parser library](https://github.com/functionhaus/arcdown).

Archivist is inspired by the general approach of Cẩm Huỳnh's great
[Nabo](https://github.com/qcam/nabo) library with some key differences:

* Archivist articles are formatted in `Arcdown` format by default, allowing
for more robust articles and article features.

* Archivist allows articles to be organized into nested *topic* directories for
better organization. Topic directory and sub-directory naming will be translated
into a hierarchical system-wide topic and sub-topic structure.

* Archivist supports the use of an "intermediate library pattern", where
content and articles are stored in a dedicated library and seperate repository
in order to reduce content-related git clutter in your primary application
repo.

* Archivist currently doesn't parse article content as markdown, but will add
optional content parsing in future versions (like 0.3.x).

* Archivist adds default attributes for author names and email addresses, as
well as sorting content by author.

* Archivist exposes its article sorting mechanism as an anonymous function,
allowing you to implement custom article-sorting strategies at compile-time.

* Archivist allows you to set a `created_at` and `published_at` timestamps to
give you greater control over content and how it's used.

* Archivist allows you to *tag* your articles however you'd like, and provides
functions for sorting and collecting all tags used across your archive.

* Archivist generates lists of tags, topics, and authors at compile-time, giving
you more flexibility in your content's front-end presentation without having to
perform additional parsing at runtime.

* Archivist allows you to set constrained lists of `valid_topics` and
`valid_tags`, and will throw warnings during compilation if tags and topics are
used that do not appear in those lists.

* Archivist allows you to store image files and parse and reference the paths to
those files within your archive at `archive/images`

## Installation

The package can be installed by adding `archivist` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:archivist, "~> 0.2"}
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

# the alias is just a nicety here and isn't required by any means
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

Archivist 0.2.x versions expect you to create your article content directory at
`priv/archive/articles` at the root of your elixir library, like this:

`priv/archive/articles/journey_to_the_center_of_the_earth.ad`

If you'd like to customize any of your archive's behavior, you can define any of
the following options when it is used in the target archive directory. The values
shown are the defaults:

```elixir
defmodule MyApp.Archive
  use Archivist.Archive
    archive_dir: "priv/archive",
    content_dir: "articles",
    content_pattern: "**/*.ad",
    image_dir: "images",
    image_pattern: "**/*.{jpg,gif,png}",
    article_sorter: &(Map.get(&1, :published_at) >= Map.get(&2, :published_at)),
    application: nil,
    valid_tags: nil,
    valid_topics: nil
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

`0.2.x` and `0.1.x` versions of Archivist will parse and return article content
as `Archivist.Article` structs. The parsing output of the above article example
would look like this:

```elixir
%Archivist.Article{
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
      {:archivist, "~> 0.2"},
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

## Topics and Tags Constraints

As of Archivist version `0.2.6` archives can receive flags for lists of
`valid_topics` and `valid_tags` like this:

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
    ]
end
```

Adding articles with tags or topics that don't conform to these lists, or using
a topic directory structure that doesn't conform to these lists will throw
warnings at compile time, like this:

```
warning: Archivist Archive contains invalid topics: Action, Classic
  (archivist) lib/archivist/parsers/article_parser.ex:77: Archivist.ArticleParser.warn_invalid/3

warning: Archivist Archive contains invalid tags: action, adventure
  (archivist) lib/archivist/parsers/article_parser.ex:77: Archivist.ArticleParser.warn_invalid/3
```

Compilation will not cease, however, simply because these constraints are
being violated.

Please note that only exact topic matches are accounted for here, so`"Sci-Fi"`
will not be considered equivalent to `"SciFi"` and will throw a warning.

If you do not want warnings for tags or topics during compilation simply don't
declare any values for `valid_topics` or `valid_tags` and they'll be ignored.

Also note that enforcement of valid topics currently is only compared to the
flattened list of topics and sub-topics. There is no functionality in place
at the moment for constraining specific topic hierarchies.

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

A quick review of the `Archivist.Archive` implementation would reveal additional
options that aren't otherwise mentioned in this README:

```elixir
defmodule MyApp.Archive
  use Archivist.Archive
    content_parser: Earmark,
    article_parser: Arcdown
end
```

These options are currently placeholders for future functionality but do not
serve any purpose to the user for the time being. Some notes on forthcoming
features:

* While `Earmark` is included with Archivist, functionality for parsing content
as Earmark has not yet been added. Future versions (like 0.3.x) will add
something like a `parsed_content` attribute to the parsed articles flag, which
will contain content parsed as Earmark. Setting this value to `nil` will cause
the article parser not to parse the content at compile-time.

* Also note that that swapping out the content and article parsers
with different modules currently is not supported. `ContentParser` and
`ArticleParser` behaviors will be implemented in future versions (likely 0.3.x)
and will support implementing custom parsers for these elements.

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
