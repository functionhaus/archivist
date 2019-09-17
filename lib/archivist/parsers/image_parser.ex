defmodule Archivist.ImageParser do

  def get_paths(image_dir, pattern) do
    image_dir
    |> Path.relative_to_cwd
    |> Path.join([pattern])
    |> Path.wildcard
  end
end
