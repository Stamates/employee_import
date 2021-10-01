defmodule Mix.Tasks.SanitizeTest do
  use ExUnit.Case
  alias Mix.Tasks.Sanitize

  describe "run/1" do
    test "imports csv file and sorts based on provided filter" do
      Sanitize.run(["./test/test_import.csv", "output.csv", "both"])

      output_file_data = EmployeeImport.import("output.csv")

      expected_result = [
        {:ok, ["FirstName", "LastName", "Email", "Phone"]},
        {:ok, ["Jeff", "Jefferson", "jeffjeff@example.com", "555-555-5551"]},
        {:ok, ["Larry", "Larrison", "larbear@example.com", "555-555-5555"]}
      ]

      assert output_file_data == expected_result
      assert :ok == File.rm("output.csv")
    end
  end

  describe "export_error_file/1" do
    test "creates and error file" do
      errors = [%{"row" => "1", "error" => "Some error"}]

      Sanitize.export_error_file(errors)

      error_file_data = EmployeeImport.import("import_errors.csv")

      expected_result = [
        {:ok, ["row", "error"]},
        {:ok, ["1", "Some error"]}
      ]

      assert error_file_data == expected_result

      assert :ok == File.rm("import_errors.csv")
    end
  end
end
