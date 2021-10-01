defmodule EmployeeImport do
  @moduledoc """
  Functions for sanitizing the data.
  """
  alias __MODULE__

  @doc """
    Imports a CSV file and decodes the data
  """
  @spec import(String.t()) :: list(tuple())
  def import(file_name) do
    file_name
    |> File.stream!()
    |> CSV.decode()
    |> Enum.to_list()
  end

  @doc """
    Converts CSV output to a list of maps with headers as keys.
  """
  @spec convert_to_map_lists(list(tuple())) :: {list(map()), list(map())}
  def convert_to_map_lists([{:ok, header_row} | data_tuples]) do
    map_list =
      Enum.with_index(data_tuples, fn {status_atom, data}, index ->
        if status_atom == :ok do
          header_row |> Enum.zip(data) |> Enum.into(%{"order" => index + 1})
        else
          %{"row" => index + 1, "error" => data}
        end
      end)

    {Enum.reject(map_list, & &1["row"]), Enum.filter(map_list, & &1["row"])}
  end

  @doc """
    Removes duplicates from a list of maps based on the filter method provided.
    Email - removes based on duplicate email
    Phone - removes based on duplicate phone
    Both - removes based on duplicate email or phone
  """
  @spec remove_duplicates(list(map()), Strint.t()) :: list(map())
  def remove_duplicates(data, "Both") do
    data |> remove_duplicates("Email") |> remove_duplicates("Phone")
  end

  def remove_duplicates(data, filter) do
    data
    |> Enum.group_by(& &1[filter])
    |> Enum.reduce([], fn {_filter, [record | _dups]}, acc -> [record | acc] end)
    |> Enum.sort_by(& &1["order"])
  end
end
