defmodule Issues.CLI do
  import Issues.TableFormatter, only: [print_table_for_columns: 2]

  @default_count 4

  @moduledoc """
  Gets args from command line.
  If the args are `-h` or `--help`, returns help
  If they aren't passes them to the rest of the app
  """
  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  Does the work of the module
  """
  def parse_args(argv) do
    OptionParser.parse(argv,
      switches: [help: :boolean],
      aliases: [h: :help]
    )
    |> elem(1)
    |> args_to_internal_representation()
  end

  def args_to_internal_representation([user, project, count]) do
    {user, project, String.to_integer(count)}
  end

  def args_to_internal_representation([user, project]) do
    {user, project, @default_count}
  end

  def args_to_internal_representation(_) do
    :help
  end

  def process(:help) do
    IO.puts("""
    usage: issues <user> <project> [count | #{@default_count}]
    """)

    System.halt()
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response()
    |> sort_into_descending_order()
    |> last(count)
    |> print_table_for_columns(["number", "created_at", "title"])
  end

  def decode_response({:ok, body}), do: body

  def decode_response({:error, error}) do
    IO.puts("Error fetching from Github: #{error["message"]}")
    System.halt(2)
  end

  def sort_into_descending_order(list_of_issues) do
    list_of_issues
    |> Enum.sort(fn issue_1, issue_2 ->
      issue_1["created_at"] >= issue_2["created_at"]
    end)
  end

  def last(list, count) do
    list
    |> Enum.take(count)
    |> Enum.reverse()
  end
end

# Why is run a convention?
# Where should @default_count be placed
