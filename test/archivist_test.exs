defmodule ArchivistTest do
  use ExUnit.Case
  doctest Archivist
  require Logger

  test "constructs the correct matcher glob" do
    Logger.debug inspect(Archivist.article_glob)
    assert Archivist.article_glob() =~ "priv/articles/**/*.ad"
  end
end
