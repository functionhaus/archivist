defmodule LocalArchive do
  use Archivist.Archive,
    archive_dir: "test/support/archive",
    valid_topics: [
      "Action",
      "Classic",
      "Crime",
      "Fiction",
      "Films",
      "Sci-Fi"
    ],
    valid_tags: [
      :action,
      :adventure,
      :aliens,
      :crime,
      :horror,
      :literature,
      :modern_classic,
      :sci_fi,
      :thrillers
    ]

end

defmodule RemoteArchive do
  # you would never call archivist in a real-world example, but it's bein used
  # here to test the resolution relative to the current app's priv directory

  use Archivist.Archive,
    archive_dir: "archive",
    application: :archivist,
    valid_topics: [
      "Action",
      "Classic",
      "Crime",
      "Fiction",
      "Films",
      "Sci-Fi"
    ],
    valid_tags: [
      :action,
      :adventure,
      :aliens,
      :crime,
      :horror,
      :literature,
      :modern_classic,
      :sci_fi,
      :thrillers
    ]
end

defmodule ArchiveTest do
  use ExUnit.Case, async: true

  test "generates a list of article paths" do
    assert LocalArchive.article_paths() ==
      [
        "test/support/archive/articles/Fiction/Sci-Fi/Classic/journey_to_the_center_of_the_earth.md.ad",
        "test/support/archive/articles/Films/Action/Crime/heat.md.ad",
        "test/support/archive/articles/Films/Sci-Fi/Classic/the_day_the_earth_stood_still.ad"
      ]
  end

  test "parses a list of articles" do
    assert LocalArchive.articles() == [
      %Archivist.Article{
        author: "Jules Verne",
        content: "Journey to the Center of the Earth (French: Voyage au centre de la Terre, also\ntranslated under the titles A Journey to the Centre of the Earth and A Journey\nto the Interior of the Earth) is an 1864 science fiction novel by Jules Verne.\nThe story involves German professor Otto Lidenbrock who believes there are\nvolcanic tubes going toward the centre of the Earth. He, his nephew Axel, and\ntheir guide Hans descend into the Icelandic volcano Snæfellsjökull, encountering\nmany adventures, including prehistoric animals and natural hazards, before\neventually coming to the surface again in southern Italy, at the Stromboli\nvolcano.\n",
        created_at: ~U[1863-09-10 20:24:00Z], email: "jules@verne.com",
        published_at: ~U[1864-09-16 11:30:00Z], slug: "journey-to-the-center-of-the-earth",
        summary: "A classic sci-fi novel about an expedition to the center of the Earth",
        tags: [:sci_fi, :adventure, :literature], title: "Journey to the Center of the Earth",
        topics: ["Fiction", "Sci-Fi","Classic"]
      },

      %Archivist.Article{
        author: "Julian Blaustein",
        content: "The Day the Earth Stood Still (a.k.a. Farewell to the Master and Journey to the\nWorld) is a 1951 American black-and-white science fiction film from 20th Century\nFox, produced by Julian Blaustein and directed by Robert Wise.\n",
        created_at: ~U[2019-01-20 22:24:00Z], email: "julian@blaustein.com",
        published_at: ~U[2019-04-02 04:30:00Z], slug: "the-day-the-earth-stood-still",
        summary: "A sci-fi classic about a flying saucer landing in Washington, D.C.",
        tags: [:sci_fi, :horror, :thrillers, :aliens], title: "The Day the Earth Stood Still",
        topics: ["Films", "Sci-Fi", "Classic"]
      },

      %Archivist.Article{
        author: "Michael Mann",
        content: "Heat is a 1995 American neo-noir crime film written, produced, and directed by\nMichael Mann, starring Al Pacino, Robert De Niro, and Val Kilmer. De Niro plays\nNeil McCauley, a seasoned professional at robberies, and Pacino plays Lt.\nVincent Hanna, an LAPD robbery-homicide detective tracking down Neil's crew\nafter a botched heist leaves three security guards dead. The story is based on\nthe former Chicago police officer Chuck Adamson's pursuit during the 1960s of a\ncriminal named McCauley, after whom De Niro's character is named. Heat is a\nremake by Mann of an unproduced television series he had worked on, the pilot of\nwhich was released as the TV movie L.A. Takedown in 1991.\n",
        created_at: ~U[1995-02-20 22:24:00Z], email: "michael@mann.org",
        published_at: ~U[1996-04-02 04:30:00Z], slug: "heat",
        summary: "A modern classic about the fine line between good and evil",
        tags: [:modern_classic, :action, :crime],
        title: "Heat",
        topics: ["Films", "Action", "Crime"],
      }
    ]
  end

  test "compile list of image paths" do
    assert LocalArchive.image_paths() == [
      "test/support/archive/images/2001.jpg",
      "test/support/archive/images/big_lebowski.png",
      "test/support/archive/images/chameleon.jpg",
      "test/support/archive/images/michael.gif"
    ]
  end

  test "compile sorted list of unique authors" do
    assert LocalArchive.authors() == [
      "Jules Verne",
      "Julian Blaustein",
      "Michael Mann"
    ]
  end

  test "compile hierarchical list of topics" do
    assert LocalArchive.topics() == %{
      "Fiction" => %{
        "Sci-Fi" => %{
          "Classic" => %{}
        },
      },
      "Films" => %{
        "Sci-Fi" => %{
          "Classic" => %{}
        },
        "Action" => %{
          "Crime" => %{}
        }
      }
    }
  end

  test "compile a flattened list of all topics and sub-topics" do
    assert LocalArchive.topics_list() == [
      "Action",
      "Classic",
      "Crime",
      "Fiction",
      "Films",
      "Sci-Fi"
    ]
  end

  test "compiled sorted list of unique tags" do
    assert LocalArchive.tags() == [
      :action,
      :adventure,
      :aliens,
      :crime,
      :horror,
      :literature,
      :modern_classic,
      :sci_fi,
      :thrillers
    ]
  end

  test "compiled sorted list of unique slugs" do
    assert LocalArchive.slugs() == [
      "heat",
      "journey-to-the-center-of-the-earth",
      "the-day-the-earth-stood-still"
    ]
  end

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
