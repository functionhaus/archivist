defmodule ArchivistMock do
  use Archivist
end

defmodule ArchivistTest do
  use ExUnit.Case, async: false

  test "parses a list of articles" do
    assert ArchivistMock.articles == "some articles"
  end
end
