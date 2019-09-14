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

  {:ok, articles} = Archive.all
  {:ok, authors} = Archive.authors
  {:ok, tags} = Archive.tags
  {:ok, topics} = Archive.topics
  {:ok, titles} = Archive.titles
  {:ok, slugs} = Archive.slugs

  {:ok, created_asc} = Archive.sort_by :created_at, :asc
  {:ok, published_desc} = Archive.sort_by :published_at, :desc
  {:ok, article} = Archive.fetch_by :slug, "some-article"
  """

  @doc false
  defmacro __using__(options) do
    quote bind_quoted: [options: options], unquote: true do
      @defaults [
        content_dir: "priv/articles",
        match_pattern: "**/*.ad",
        article_sorter: &(&1[:published_at] >= &2[:published_at]),
        content_parser: Earmark,
        article_parser: Arcdown
      ]

      @settings Keyword.merge(@defaults, options)

      @before_compile unquote(__MODULE__)
    end
  end

  alias Archivist.ArticleParser, as: Parser

  @doc false
  defmacro __before_compile__(env) do
    settings = Module.get_attribute(env.module, :settings)

    content_dir = settings[:content_dir]
    match_pattern = settings[:match_pattern]
    article_sorter = settings[:article_sorter]
    article_parser = settings[:article_parser]

    article_paths = Parser.get_paths(content_dir, match_pattern)
    parsed_articles = Parser.parse_files(article_paths, article_parser)
    valid_articles = Parser.filter_valid(parsed_articles)

    topics = Parser.parse_attrs(:topics, valid_articles)
    tags = Parser.parse_attrs(:tags, valid_articles)
    authors = Parser.parse_attr(:author, valid_articles)
    slugs = Parser.parse_attr(:slug, valid_articles)

    # quote individual article paths as external resources so that they can be
    # tracked later for autoloading, etc.
    external_resources = article_paths
      |> Enum.map(&quote(do: @external_resource unquote(&1)))

    quote do
      unquote(external_resources)

      def articles do
        unquote valid_articles
          |> Enum.sort(article_sorter)
          |> Macro.escape
      end

      def article_paths do
        unquote article_paths
      end

      def topics do
        unquote topics
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