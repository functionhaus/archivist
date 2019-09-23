defmodule RemoteArchiveTest do
  use ExUnit.Case, async: true

  test "remote archive should use priv paths" do
    priv_dir = :code.priv_dir(:archivist)

    expected_paths = [
      "archive/images/2001.jpg",
      "archive/images/big_lebowski.png",
      "archive/images/chameleon.jpg",
      "archive/images/michael.gif"
    ] |> Enum.map(&Path.join(priv_dir, &1))

    assert RemoteArchive.image_paths() == expected_paths
  end

  test "generates a list of remote article paths" do
    priv_dir = :code.priv_dir(:archivist)

    expected_paths = [
      "archive/articles/Fiction/Sci-Fi/Classic/journey_to_the_center_of_the_earth.md.ad",
      "archive/articles/Films/Action/Crime/heat.md.ad",
      "archive/articles/Films/Sci-Fi/Classic/the_day_the_earth_stood_still.ad"
    ] |> Enum.map(&Path.join(priv_dir, &1))

    assert RemoteArchive.article_paths() == expected_paths
  end
end
