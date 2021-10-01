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

    {sanitized_data, errors} =
      input_file
      |> EmployeeImport.import()
      |> EmployeeImport.convert_to_map_lists()

    if sanitized_data != [] do
      sanitized_data
      |> EmployeeImport.remove_duplicates(String.capitalize(filter))
      |> export_data(output_file)
    end

    if errors != [], do: export_error_file(errors)
    :ok
  end

  @spec export_data(list(), String.t()) :: :ok
  def export_data(employee_data, output_file) do
    output_file = File.open!("#{output_file}", [:write, :utf8])

    employee_data
    |> CSV.encode(headers: ["FirstName", "LastName", "Email", "Phone"])
    |> Enum.each(&IO.write(output_file, &1))

    File.close(output_file)
  end

  @spec export_error_file(list()) :: :ok
  def export_error_file(errors) do
    error_file = File.open!("import_errors.csv", [:write, :utf8])

    errors
    |> CSV.encode(headers: ["row", "error"])
    |> Enum.each(&IO.write(error_file, &1))

    File.close(error_file)
  end
end
