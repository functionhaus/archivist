defmodule Archivist do
  @moduledoc """
  Documentation for Archivist.
  """

  # @articles

  # @topics

  # @tags

  # @authors

  def article_paths do
    article_glob()
    |> Path.wildcard
  end

  def article_glob do
    Path.relative_to_cwd("priv/articles")
    |> Path.join(["**/*.ad"])
  end
end
