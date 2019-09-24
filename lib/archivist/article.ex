defmodule Archivist.Article do
  @moduledoc """
  The core datatype for Archivist. Articles are broken into header and
  body/content parts then compiled into the %Archivist.Article{} struct.
  """

  @type t :: %__MODULE__{
    title: String.t(),
    author: String.t(),
    email: String.t(),
    summary: String.t(),
    content: String.t(),
    parsed_content: String.t(),
    topics: [String.t()],
    tags: [atom()],
    slug: String.t(),
    created_at: DateTime.t,
    published_at: DateTime.t
  }

  defstruct [
    :title,
    :author,
    :email,
    :summary,
    :content,
    :parsed_content,
    :topics,
    :tags,
    :slug,
    :created_at,
    :published_at
  ]
end
