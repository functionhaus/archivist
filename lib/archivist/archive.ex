defmodule Archivist.Archive do

  @moduledoc """
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
      article_parser: &Arcdown.parse_file(&1),
      article_sorter: &(Map.get(&1, :published_at) >= Map.get(&2, :published_at)),
      slug_warnings: true,
      application: nil,
      valid_tags: nil,
      valid_topics: nil,
      valid_authors: nil,
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
  """

  @doc false
  defmacro __using__(options) do
    quote bind_quoted: [options: options], unquote: true do
      @defaults [
        archive_dir: "priv/archive",
        content_dir: "articles",
        content_pattern: "**/*.ad",
        image_dir: "images",
        image_pattern: "**/*.{jpg,gif,png}",
        article_sorter: &(Map.get(&1, :published_at) >= Map.get(&2, :published_at)),
        article_parser: &Arcdown.parse_file(&1),
        content_parser: &Earmark.as_html!(&1),
        content_parser: nil,
        application: nil,
        slug_warnings: true,
        valid_tags: nil,
        valid_topics: nil,
        valid_authors: nil
      ]

      @settings Keyword.merge(@defaults, options)

      @before_compile unquote(__MODULE__)
    end
  end

  alias Archivist.ArticleParser, as: Parser
  alias Archivist.Article

  @doc false
  defmacro __before_compile__(env) do
    settings = Module.get_attribute(env.module, :settings)

    application = settings[:application]
    archive_dir = settings[:archive_dir]
    content_dir = settings[:content_dir]
    content_pattern = settings[:content_pattern]
    image_dir = settings[:image_dir]
    image_pattern = settings[:image_pattern]
    article_sorter = settings[:article_sorter]
    article_parser = settings[:article_parser]
    content_parser = settings[:content_parser]
    slug_warnings = settings[:slug_warnings]
    valid_topics = settings[:valid_topics]
    valid_tags = settings[:valid_tags]
    valid_authors = settings[:valid_authors]

    article_paths = Parser.build_paths(archive_dir, content_dir, content_pattern, application)
    image_paths = Parser.build_paths(archive_dir, image_dir, image_pattern, application)

    articles = Stream.map(article_paths, article_parser)
      |> Parser.filter_valid
      |> Parser.convert_structs(Article)
      |> Parser.parse_content(content_parser)

    topics_list = Parser.parse_topics_list(articles, valid_topics)
    topics = Parser.parse_topics(articles)
    tags = Parser.parse_tags(articles, valid_tags)
    authors = Parser.parse_authors(articles, valid_authors)
    slugs = Parser.parse_slugs(articles, slug_warnings)

    # quote individual article paths as external resources so that they can be
    # tracked later for autoloading, etc.
    external_resources = article_paths
      |> Enum.map(&quote(do: @external_resource unquote(&1)))

    quote do
      unquote(external_resources)

      def articles do
        unquote articles
          |> Enum.sort(article_sorter)
          |> Macro.escape
      end

      def article_paths do
        unquote article_paths
      end

      def image_paths do
        unquote image_paths
      end

      def topics do
        unquote Macro.escape(topics)
      end

      def topics_list do
        unquote topics_list
      end

      def tags do
        unquote tags
      end

      def authors do
        unquote authors
      end

      def slugs do
        unquote slugs
      end
    end
  end
end
