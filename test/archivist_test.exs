defmodule ArchivistTest do
  use ExUnit.Case, async: false
  doctest Archivist
  require Logger

  test "constructs the correct matcher glob" do
    assert Archivist.article_glob() =~ "priv/articles/**/*.ad"
  end

  test "finds the correct article paths" do
    :meck.expect(Archivist, :content_dir, fn()-> "test/support/articles" end)
    assert Archivist.article_glob() == "test/support/articles/**/*.ad"
  end
end
