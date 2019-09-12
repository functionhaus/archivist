defmodule ArchivistTest do
  use ExUnit.Case
  import Mox

  doctest Archivist

  setup :set_mox_global
  setup :verify_on_exit!

  test "constructs the correct matcher glob" do
    assert Archivist.article_glob() =~ "priv/articles/**/*.ad"
  end

  test "finds the correct article paths" do
    expect(ArchMock, :content_dir, fn -> "test/support/articles" end)
    assert ArchMock.article_glob() == "test/support/articles/**/*.ad"
  end
end
