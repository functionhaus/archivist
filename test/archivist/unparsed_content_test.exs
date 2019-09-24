defmodule UnparsedContentTest do
  use ExUnit.Case, async: true

  test "parses a list of articles" do
    assert UnparsedContentArchive.articles() == [
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

end
