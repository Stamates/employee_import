defmodule EmployeeImportTest do
  use ExUnit.Case
  doctest EmployeeImport

  test "greets the world" do
    assert EmployeeImport.hello() == :world
  end
end
