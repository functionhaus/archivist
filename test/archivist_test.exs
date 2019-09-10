defmodule ArchivistTest do
  use ExUnit.Case
  doctest Archivist

  test "greets the world" do
    assert Archivist.hello() == :world
  end
end
