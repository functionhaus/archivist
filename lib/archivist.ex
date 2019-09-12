defmodule Archivist do
  @moduledoc """
  Documentation for Archivist.
  """

  @content_dir "priv/articles"
  @match_pattern "**/*.ad"

  # @articles

  # @topics

  # @tags

  # @authors

  def article_paths() do
    article_glob()
    |> Path.wildcard
  end

  def article_glob() do
    __MODULE__.content_dir()
    |> Path.relative_to_cwd
    |> Path.join([match_pattern()])
  end

  def content_dir() do
    @content_dir
  end

  def match_pattern() do
    @match_pattern
  end
end
