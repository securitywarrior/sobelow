defmodule Sobelow.SQL.Query do
  alias Sobelow.Utils
  use Sobelow.Finding
  @finding_type "SQL injection"

  def run(fun, filename) do
    {findings, params, {fun_name, [{_, line_no}]}} = parse_sql_def(fun)
    severity = if String.ends_with?(filename, "_controller.ex"), do: false, else: :low

    Enum.each(findings, fn {finding, var} ->
      Utils.add_finding(line_no, filename, fun, fun_name,
                        var, Utils.get_sev(params, var, severity),
                        finding, @finding_type)
    end)

    {findings, params, {fun_name, [{_, line_no}]}} = parse_repo_query_def(fun)

    Enum.each(findings, fn {finding, var} ->
      Utils.add_finding(line_no, filename, fun, fun_name,
                        var, Utils.get_sev(params, var, severity),
                        finding, @finding_type)
    end)
  end

  ## query(repo, sql, params \\ [], opts \\ [])
  def parse_sql_def(fun) do
    Utils.get_fun_vars_and_meta(fun, 1, :query, :SQL)
  end

  def parse_repo_query_def(fun) do
    Utils.get_fun_vars_and_meta(fun, 0, :query, :Repo)
  end

  def details() do
    Sobelow.SQL.details()
  end
end
