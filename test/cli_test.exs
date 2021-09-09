defmodule CLITest do
  use ExUnit.Case
  doctest Issues

  import Issues.CLI, only: [parse_args: 1, sort_into_descending_order: 1]

  test ":help is returned when `-h` or `--help` is given" do
    assert parse_args(["--help", "anything"]) == :help
    assert parse_args(["-h", "anything"]) == :help
  end

  test "three values returned when three given" do
    assert parse_args(["name", "project", "99"]) == {"name", "project", 99}
  end

  test "default count used when two values given" do
    assert parse_args(["name", "project"]) == {"name", "project", 4}
  end

  test "sort descending order the correct way" do
    result = sort_into_descending_order(fake_created_at_list(["c", "a", "b"]))
    issues = for issue <- result, do: Map.get(issue, "created_at")
    assert issues == ~w{ c b a }
  end

  defp fake_created_at_list(values) do
    for value <- values do
      %{"created_at" => value, "other_data" => "xxx"}
    end
  end
end
