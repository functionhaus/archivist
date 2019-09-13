defmodule ArchivistMock do
  use Archivist, content_dir: "test/support/articles"
end

defmodule ArchivistTest do
  use ExUnit.Case, async: false

  test "generates a list of article paths" do
    assert ArchivistMock.article_paths() ==
      ["test/support/articles/the_day_the_earth_stood_still.ad"]
  end

  test "parses a list of articles" do
    assert ArchivistMock.articles() == [
      %Arcdown.Article{
        author: "Julian Blaustein",
        content: "The Day the Earth Stood Still (a.k.a. Farewell to the Master and Journey to the\nWorld) is a 1951 American black-and-white science fiction film from 20th Century\nFox, produced by Julian Blaustein and directed by Robert Wise.\n",
        created_at: ~U[2019-01-20 22:24:00Z],
        email: "julian@blaustein.com",
        published_at: ~U[2019-04-02 04:30:00Z],
        slug: "the-day-the-earth-stood-still",
        summary: "A sci-fi classic about a flying saucer landing in Washington, D.C.",
        tags: [:sci_fi, :horror, :thrillers, :aliens],
        title: "The Day the Earth Stood Still",
        topics: ["Films", "Sci-Fi", "Classic"]
      }
    ]
  end

  test "compile sorted list of unique authors" do
    assert ArchivistMock.authors() == ["Julian Blaustein"]
  end

  test "compile sorted list of unique topics" do
    assert ArchivistMock.topics() == ["Classic", "Films", "Sci-Fi"]
  end

  test "compiled sorted list of unique tags" do
    assert ArchivistMock.tags() == [:aliens, :horror, :sci_fi, :thrillers]
  end

  test "compiled sorted list of unique slugs" do
    assert ArchivistMock.slugs() == ["the-day-the-earth-stood-still"]
  end
end
