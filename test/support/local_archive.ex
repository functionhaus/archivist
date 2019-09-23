defmodule LocalArchive do
  use Archivist.Archive,
    archive_dir: "test/support/archives/local"
end
