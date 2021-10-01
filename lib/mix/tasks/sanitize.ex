defmodule Mix.Tasks.Sanitize do
  @moduledoc """
  This task will import employee records from a CSV file and return a CSV file
  with duplicates removed based on the specified filtering strategy
  `mix sanitize csv_file filter_strategy`

  filter strategy: email, phone, or both
  """

  use Mix.Task
  alias EmployeeImport

  def run([input_file, output_file, filter]) do
    Mix.Task.run("app.start")

    case EmployeeImport.verify_filter(filter) do
      {:ok, filter_stratey} ->
        {sanitized_data, errors} =
          input_file
          |> EmployeeImport.import()
          |> EmployeeImport.convert_to_map_lists()

        maybe_export_data(sanitized_data, output_file, filter_stratey)
        maybe_export_errors(errors)

      {:error, error} ->
        IO.puts(error)
    end
  rescue
    _ -> IO.puts("Input file not found")
  end

  def run(_args),
    do: IO.puts("Call must match pattern mix sanitize <input_file> <output_file> <filter>")

  @spec export_file(list(), String.t(), list()) :: :ok
  def export_file(employee_data, output_file, headers) do
    output_file = File.open!("#{output_file}", [:write, :utf8])

    employee_data
    |> CSV.encode(headers: headers)
    |> Enum.each(&IO.write(output_file, &1))

    File.close(output_file)
  end

  defp maybe_export_data([], _output_file), do: :ok

  defp maybe_export_data(sanitized_data, output_file, filter) do
    sanitized_data
    |> EmployeeImport.remove_duplicates(filter)
    |> export_file(output_file, ["FirstName", "LastName", "Email", "Phone"])
  end

  defp maybe_export_errors([]), do: :ok
  defp maybe_export_errors(errors), do: export_file(errors, "import_errors.csv", ["row", "error"])
end
