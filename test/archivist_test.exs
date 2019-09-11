defmodule ArchivistTest do
  use ExUnit.Case
  doctest Archivist
  require Logger

  test "constructs the correct matcher glob" do
    Logger.debug inspect(Archivist.article_glob)
    assert Archivist.article_glob() =~ "priv/articles/**/*.ad"
  end

  test "finds the correct article paths" do
    :meck.expect(Archivist, :article_glob, fn()-> "test/support/articles/**/*.ad" end)
    assert Archivist.article_glob() == "test/support/articles/**/*.ad"
  end
end
