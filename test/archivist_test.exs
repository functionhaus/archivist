defmodule ArchivistTest do
  use ExUnit.Case, async: false

  test "parses a list of articles" do
    assert Archivist.articles == "some articles"
  end
end
