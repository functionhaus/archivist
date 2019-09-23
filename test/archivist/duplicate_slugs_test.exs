defmodule DupSlugsArchiveTest do
  use ExUnit.Case, async: true

  test "warnings should be thrown on duplicate slugs" do
    assert DupSlugsArchive.slugs() == [
        "the-day-the-earth-stood-still",
        "the-day-the-earth-stood-still",
        "the-day-the-earth-stood-still"
      ]
  end
end
