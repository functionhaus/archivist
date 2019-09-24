defmodule UnparsedContentArchive do
  use Archivist.Archive,
    archive_dir: "test/support/archives/local",
    content_parser: nil
end
