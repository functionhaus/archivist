defmodule Archivist.Archive do

  @moduledoc """
  Module that coordinates the structured parsing and return of assets in the
  articles root directory.

  Precompiles and provides interface to interact with your articles.

  By most Elixir and Erlang conventions this module should be called
  'Archivist.Repo' since it's being used for data access, but this library is
  called Archivist so we're calling it an Archive. Deal with it.

  defmodule MyApp.Archive do
    use Archivist.Archive,
      root: "some/other/dir",
      body_parser: Earmark

  end

  alias MyApp.Archive

  {:ok, articles} = Archive.all()
  {:ok, authors} = Archive.authors()
  {:ok, image_paths} = Archive.image_paths()
  {:ok, tags} = Archive.tags()
  {:ok, topics} = Archive.topics()
  {:ok, titles} = Archive.titles()
  {:ok, slugs} = Archive.slugs()

  {:ok, created_asc} = Archive.sort_by :created_at, :asc
  {:ok, published_desc} = Archive.sort_by :published_at, :desc
  {:ok, article} = Archive.fetch_by :slug, "some-article"
  """

  @doc false
  defmacro __using__(options) do
    quote bind_quoted: [options: options], unquote: true do
      @defaults [
        content_dir: "priv/articles",
        content_pattern: "**/*.ad",
        image_dir: "priv/images",
        image_pattern: "**/*.{jpg,gif,png}",
        article_sorter: &(Map.get(&1, :published_at) >= Map.get(&2, :published_at)),
        content_parser: Earmark,
        article_parser: Arcdown
      ]

      @settings Keyword.merge(@defaults, options)

      @before_compile unquote(__MODULE__)
    end
  end

  alias Archivist.ArticleParser, as: Parser
  alias Archivist.Article
  alias Archivist.ImageParser

  @doc false
  defmacro __before_compile__(env) do
    settings = Module.get_attribute(env.module, :settings)

    content_dir = settings[:content_dir]
    content_pattern = settings[:content_pattern]

    image_dir = settings[:image_dir]
    image_pattern = settings[:image_pattern]

    article_sorter = settings[:article_sorter]
    article_parser = settings[:article_parser]

    article_paths = Parser.get_paths(content_dir, content_pattern)
    articles = Parser.parse_files(article_paths, article_parser)
      |> Parser.filter_valid
      |> Stream.map(&Map.from_struct(&1))
      |> Stream.map(&struct(Article, &1))

    image_paths = ImageParser.get_paths(image_dir, image_pattern)

    topics = Parser.parse_topics(articles)
    topics_list = Parser.parse_attrs(:topics, articles)
    tags = Parser.parse_attrs(:tags, articles)
    authors = Parser.parse_attr(:author, articles)
    slugs = Parser.parse_attr(:slug, articles)

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
