defmodule Archivist.EnumUtils do
  def split_uniq(enumerable) do
    split_uniq_by(enumerable, fn x -> x end)
  end

  def split_uniq_by(enumerable, fun) when is_list(enumerable) do
    split_uniq_list(enumerable, %{}, fun)
  end

  defp split_uniq_list([head | tail], set, fun) do
    value = fun.(head)

    case set do
      %{^value => true} ->
        {uniq, dupl} = split_uniq_list(tail, set, fun)
        {uniq, [head | dupl]}

      %{} ->
        {uniq, dupl} = split_uniq_list(tail, Map.put(set, value, true), fun)
        {[head | uniq], dupl}
    end
  end

  defp split_uniq_list([], _set, _fun) do
    {[], []}
  end
end

