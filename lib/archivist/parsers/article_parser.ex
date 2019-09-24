defmodule Archivist.ArticleParser do

  alias Archivist.MapUtils
  alias Archivist.EnumUtils

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

  def parse_content(articles_stream, parser) do
    case parser do
      nil -> articles_stream
      _ ->
        Stream.map(articles_stream, fn article ->
          content = Map.get(article, :content)
          parsed_content = parser.(content)
          Map.put(article, :parsed_content, parsed_content)
        end)
    end
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

  def parse_topics_list(articles, valid_topics) do
    parse_attrs(:topics, articles)
    |> warn_invalid(valid_topics, :topics)
  end

  def parse_tags(articles, valid_tags) do
    parse_attrs(:tags, articles)
    |> warn_invalid(valid_tags, :tags)
  end

  def parse_authors(articles, valid_authors) do
    parse_attr(:author, articles)
    |> warn_invalid(valid_authors, :authors)
  end

  def parse_slugs(articles, slug_warnings) do
    articles
    |> Stream.map(&Map.get(&1, :slug))
    |> Stream.reject(&is_nil/1)
    |> Enum.sort
    |> warn_duplicate(slug_warnings, :slugs)
  end

  defp warn_invalid(parsed_items, valid_items, attr_name) do
    if valid_items do
      invalid_items = Enum.filter(parsed_items, fn item ->
        !Enum.member?(valid_items, item)
      end)

      if Enum.count(invalid_items) > 0 do
        joined_items = Enum.join(invalid_items, ", ")
        "Archivist Archive contains invalid #{attr_name}: #{joined_items}"
        |> IO.warn(Macro.Env.stacktrace(__ENV__))
      end
    end

    parsed_items
  end

  defp warn_duplicate(items, warnings, attr_name) do
    if warnings do

      {_uniqs, duplicates} = EnumUtils.split_uniq(items)

      if Enum.count(duplicates) > 0 do
        joined_dups = Enum.join(duplicates, ", ")
        "Archivist Archive contains duplicate #{attr_name}: #{joined_dups}"
        |> IO.warn(Macro.Env.stacktrace(__ENV__))
      end
    end

    items
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
