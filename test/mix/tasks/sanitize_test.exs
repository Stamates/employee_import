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

    test "provides message if input file not found" do
      assert Sanitize.run(["./test/non_existent.csv", "output.csv", "both"]) ==
               :ok
    end

    test "provides message if all args are not provided" do
      assert Sanitize.run([]) == :ok
    end
  end

  describe "export_file/1" do
    test "creates an employee file" do
      data = [
        %{
          "FirstName" => "Another",
          "LastName" => "Person",
          "Email" => "another_person@example.com",
          "Phone" => "555-555-5551",
          "order" => 1
        }
      ]

      Sanitize.export_file(data, "output_file.csv", ["FirstName", "LastName", "Email", "Phone"])

      file_data = EmployeeImport.import("output_file.csv")

      expected_result = [
        {:ok, ["FirstName", "LastName", "Email", "Phone"]},
        {:ok, ["Another", "Person", "another_person@example.com", "555-555-5551"]}
      ]

      assert file_data == expected_result

      assert :ok == File.rm("output_file.csv")
    end

    test "creates an error file" do
      errors = [%{"row" => "1", "error" => "Some error"}]

      Sanitize.export_file(errors, "import_errors.csv", ["row", "error"])

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
