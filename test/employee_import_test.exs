defmodule EmployeeImportTest do
  use ExUnit.Case

  describe "verify_filter/1" do
    test "succeeds when passed correct value" do
      assert {:ok, "Both"} == EmployeeImport.verify_filter("Both")
    end

    test "capitalizes correct input" do
      assert {:ok, "Email"} == EmployeeImport.verify_filter("emAIl")
    end

    test "returns error tuple if not a valid filter" do
      assert {:error, "Filter must be on of email, phone, or both"} ==
               EmployeeImport.verify_filter("not_valid")
    end
  end

  describe "convert_to_map_lists/1" do
    test "converts csv data into a map with header row keys" do
      assert {[
                %{
                  "FirstName" => "Some",
                  "LastName" => "Person",
                  "Email" => "some_person@example.com",
                  "Phone" => "555-555-5555",
                  "order" => 1
                },
                %{
                  "FirstName" => "Another",
                  "LastName" => "Person",
                  "Email" => "another_person@example.com",
                  "Phone" => "555-555-5551",
                  "order" => 2
                }
              ],
              []} ==
               EmployeeImport.convert_to_map_lists([
                 {:ok, ["FirstName", "LastName", "Email", "Phone"]},
                 {:ok, ["Some", "Person", "some_person@example.com", "555-555-5555"]},
                 {:ok, ["Another", "Person", "another_person@example.com", "555-555-5551"]}
               ])
    end

    test "responds with error map_list if existing" do
      assert {[
                %{
                  "FirstName" => "Some",
                  "LastName" => "Person",
                  "Email" => "some_person@example.com",
                  "Phone" => "555-555-5555",
                  "order" => 1
                }
              ],
              [%{"row" => 2, "error" => "Something's wrong"}]} ==
               EmployeeImport.convert_to_map_lists([
                 {:ok, ["FirstName", "LastName", "Email", "Phone"]},
                 {:ok, ["Some", "Person", "some_person@example.com", "555-555-5555"]},
                 {:error, "Something's wrong"}
               ])
    end
  end

  describe "remove_duplicates/2" do
    setup do
      data = [
        %{
          "FirstName" => "Jeff",
          "LastName" => "Jefferson",
          "Email" => "jeffjeff@example.com",
          "Phone" => "555-555-5551",
          "order" => 1
        },
        %{
          "FirstName" => "Jeff",
          "LastName" => "Jefferson",
          "Email" => "jeffjeff@example.com",
          "Phone" => "555-555-5552",
          "order" => 2
        },
        %{
          "FirstName" => "Larry",
          "LastName" => "Larrison",
          "Email" => "larbear@example.com",
          "Phone" => "555-555-5555",
          "order" => 3
        },
        %{
          "FirstName" => "Larry",
          "LastName" => "Larrison",
          "Email" => "larbear2@example.com",
          "Phone" => "555-555-5555",
          "order" => 4
        },
        %{
          "FirstName" => "Jeffrey",
          "LastName" => "Jefferson",
          "Email" => "jeffjeff@example.com",
          "Phone" => "555-555-5552",
          "order" => 5
        }
      ]

      [data: data]
    end

    test "removes duplicates based on email", %{data: data} do
      result = [
        %{
          "FirstName" => "Jeff",
          "LastName" => "Jefferson",
          "Email" => "jeffjeff@example.com",
          "Phone" => "555-555-5551",
          "order" => 1
        },
        %{
          "FirstName" => "Larry",
          "LastName" => "Larrison",
          "Email" => "larbear@example.com",
          "Phone" => "555-555-5555",
          "order" => 3
        },
        %{
          "FirstName" => "Larry",
          "LastName" => "Larrison",
          "Email" => "larbear2@example.com",
          "Phone" => "555-555-5555",
          "order" => 4
        }
      ]

      assert data |> EmployeeImport.remove_duplicates("Email") |> Enum.sort_by(& &1["order"]) ==
               result
    end

    test "removes duplicates based on phone", %{data: data} do
      result = [
        %{
          "FirstName" => "Jeff",
          "LastName" => "Jefferson",
          "Email" => "jeffjeff@example.com",
          "Phone" => "555-555-5551",
          "order" => 1
        },
        %{
          "FirstName" => "Jeff",
          "LastName" => "Jefferson",
          "Email" => "jeffjeff@example.com",
          "Phone" => "555-555-5552",
          "order" => 2
        },
        %{
          "FirstName" => "Larry",
          "LastName" => "Larrison",
          "Email" => "larbear@example.com",
          "Phone" => "555-555-5555",
          "order" => 3
        }
      ]

      assert data |> EmployeeImport.remove_duplicates("Phone") |> Enum.sort_by(& &1["order"]) ==
               result
    end

    test "removes duplicates based on both email or phone", %{data: data} do
      result = [
        %{
          "FirstName" => "Jeff",
          "LastName" => "Jefferson",
          "Email" => "jeffjeff@example.com",
          "Phone" => "555-555-5551",
          "order" => 1
        },
        %{
          "FirstName" => "Larry",
          "LastName" => "Larrison",
          "Email" => "larbear@example.com",
          "Phone" => "555-555-5555",
          "order" => 3
        }
      ]

      assert data |> EmployeeImport.remove_duplicates("Both") |> Enum.sort_by(& &1["order"]) ==
               result
    end
  end
end
