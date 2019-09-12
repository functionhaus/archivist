defmodule ArchivistTest do
  use ExUnit.Case, async: false

  test "constructs the correct matcher glob" do
    assert Archivist.article_glob() =~ "priv/articles/**/*.ad"
  end

  test "constructs a list of article paths" do
    assert Archivist.article_paths() == ["priv/articles/the_day_the_earth_stood_still.ad"]
  end
end
