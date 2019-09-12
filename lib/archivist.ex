defmodule Archivist do
  @moduledoc """
  Documentation for Archivist.
  """

  # define the behaviour interface, primarily for Mox exposure
  @callback article_paths() :: [String.t]
  @callback article_glob() :: String.t
  @callback content_dir() :: String.t
  @callback match_pattern() :: String.t

  @content_dir "priv/articles"
  @match_pattern "**/*.ad"

  # @articles

  # @topics

  # @tags

  # @authors

  def article_paths do
    article_glob()
    |> Path.wildcard
  end

  def article_glob do
    @content_dir
    |> Path.relative_to_cwd
    |> Path.join([@match_pattern])
  end
end
