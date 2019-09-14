defmodule Archivist.ArticleParser do
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
    |> Stream.flat_map(fn article -> Map.get(article, attr) end)
    |> sanitize_attrs
  end

  def parse_attr(attr, articles) do
    articles
    |> Stream.map(fn article -> Map.get(article, attr) end)
    |> sanitize_attrs
  end

  defp sanitize_attrs(parsed_vals) do
    parsed_vals
    |> Stream.reject(&is_nil/1)
    |> Stream.uniq
    |> Enum.sort
  end
end
