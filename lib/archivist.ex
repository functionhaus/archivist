defmodule Archivist do
  @moduledoc """
  Module that coordinates the structured parsing and return of assets in the
  articles root directory.

  Precompiles and provides interface to interact with your articles.

  defmodule MyApp.Archive do
    use Archivist.Archive,
      root: "some/other/dir",
      body_parser: Earmark

  end

  alias MyApp.Archive

  {:ok, articles} = Archive.all
  {:ok, authors} = Archive.authors
  {:ok, created_asc} = Archive.sort_by :created_at, :asc
  {:ok, published_desc} = Archive.sort_by :published_at, :desc
  {:ok, tags} = Archive.tags
  {:ok, topics} = Archive.topics
  {:ok, titles} = Archive.titles
  {:ok, slugs} = Archive.slugs

  {:ok, article} = Archive.fetch_by :slug, "some-article"
  """

  require Logger

  @doc false
  defmacro __using__(options) do
    quote bind_quoted: [options: options], unquote: true do
      @defaults %{
        content_dir: "priv/articles",
        match_pattern: "**/*.ad",
        content_parser: Earmark,
        article_parser: Arcdown
      }

      @settings Map.merge(@defaults, options)

      @before_compile unquote(__MODULE__)
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    settings = Module.get_attribute(env.module, :settings)

    # quote individual article paths as external resources so that they can be
    # tracked later for autoloading, etc.
    #
    content_dir = settings[:content_dir]
    match_pattern = settings[:match_pattern]

    article_paths = article_paths(content_dir, match_pattern)
    articles_stream = articles_stream(article_paths)

    external_resources = article_paths
      |> Enum.map(&quote(do: @external_resource unquote(&1)))

    quote do
      unquote(external_resources)

      def articles do
        unquote Enum.to_list(articles_stream)
      end

      def topics do
        unquote parse_attrs(:topics, articles_stream)
      end

      def tags do
        unquote parse_attrs(:tags, articles_stream)
      end

      def authors do
        unquote parse_attrs(:author, articles_stream)
      end
    end
  end

  defp article_paths(content_dir, pattern) do
    content_dir
    |> Path.relative_to_cwd
    |> Path.join([pattern])
    |> Path.wildcard
  end

  defp articles_stream(article_paths) do
    Stream.map(article_paths, fn path ->
      {:ok, parsed} = Arcdown.parse_file(path)
      parsed
    end)
  end

  defp parse_attrs(attr, articles_stream) do
    articles_stream
    |> Stream.flat_map(fn article -> article[attr] end)
    |> Stream.reject(&is_nil/1)
    |> Stream.uniq
    |> Enum.sort
  end
end
