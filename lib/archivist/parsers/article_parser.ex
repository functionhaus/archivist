defmodule Archivist.ArticleParser do

  alias Archivist.MapUtils


  # if no application is given, then we just want to expand the paths relative
  # to the
  def build_paths(archive_dir, subdir, pattern, app) when is_nil(app) do
    Path.join([archive_dir, subdir, pattern])
    |> Path.relative_to_cwd
    |> Path.wildcard
  end

  def build_paths(archive_dir, subdir, pattern, app) when is_atom(app) do
    Path.join([:code.priv_dir(app), archive_dir, subdir, pattern])
    |> Path.wildcard
  end

  def parse_files(article_paths, parser) do
    Stream.map(article_paths, &parser.parse_file(&1))
  end

  def filter_valid(parsed_articles) do
    Stream.map(parsed_articles, fn tuple ->
      case tuple do
        {:ok, article} -> article
        _ -> nil
      end
    end)
    |> Stream.reject(&is_nil/1)
  end

  def convert_structs(parsed_articles, struct_type) do
    parsed_articles
    |> Stream.map(&Map.from_struct(&1))
    |> Stream.map(&struct(struct_type, &1))
  end

  def parse_attrs(attr, articles) do
    articles
    |> Stream.flat_map(&Map.get(&1, attr))
    |> sanitize_attrs
  end

  def parse_attr(attr, articles) do
    articles
    |> Stream.map(&Map.get(&1, attr))
    |> sanitize_attrs
  end

  defp sanitize_attrs(parsed_vals) do
    parsed_vals
    |> Stream.reject(&is_nil/1)
    |> Stream.uniq
    |> Enum.sort
  end

  def parse_topics(articles) do
    articles
    |> Stream.map(&Map.get(&1, :topics))
    |> Stream.map(&mapify_topics(&1))
    |> Enum.reduce(%{}, &MapUtils.deep_merge(&2, &1))
  end

  defp mapify_topics(nested_topics) do
    nested_topics
    |> Enum.reverse
    |> Enum.reduce(%{}, &Map.put(%{}, &1, &2))
  end
end
