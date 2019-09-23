defmodule DupSlugsArchive do
  use Archivist.Archive,
    archive_dir: "test/support/archives/duplicate_slugs"
end
