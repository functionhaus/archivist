defmodule Archivist.ArticleParser do

  alias Archivist.MapUtils

  def get_paths(content_dir, pattern) do
    content_dir
    |> Path.relative_to_cwd
    |> Path.join([pattern])
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
    |> Enum.reduce(%{}, fn topics_map, acc ->
      MapUtils.deep_merge(acc, topics_map)
    end)
  end

  defp mapify_topics(nested_topics) do
    nested_topics
    |> Enum.reverse
    |> Enum.reduce(%{}, fn topic, acc ->
      Map.put(%{}, topic, acc)
    end)
  end
end
