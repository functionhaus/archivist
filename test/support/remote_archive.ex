defmodule RemoteArchive do
  # it is unlikely that you would call :archivist in a real-world example,
  # but it's being used here to test the resolution relative to the current
  # app's priv directory

  use Archivist.Archive,
    archive_dir: "archive",
    application: :archivist
end
