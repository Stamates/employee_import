# EmployeeImport

Imports an employee records CSV and outputs an employee records CSV with duplicate records removed based on the filter provided (email, phone, or both).

## Running

1. Clone the repo. `git clone `
2. `cd employee_import`
3. `mix deps.get`
4. `mix sanitize <input file> <output file> <filter>`

If there are any errors during import, you'll find them in an `import_errors.csv`

