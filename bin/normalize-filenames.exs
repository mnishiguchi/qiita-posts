#! /usr/bin/env elixir
#
# Normalize blog post filenames based on updated_at and id so that they can be
# sorted by updated_at date.
#
# ## Usage
#
#   # rename files
#   bin/normalize-filenames.exs
#
#   # dry run
#   bin/normalize-filenames.exs --dry-run
#   bin/normalize-filenames.exs -n
#

Mix.install([:yaml_elixir, :timex])

{parsed_opts, _} =
  System.argv()
  |> OptionParser.parse!(
    strict: [dry_run: :boolean],
    aliases: [n: :dry_run]
  )

public_path = Path.join(File.cwd!(), "public")

for current_filename <- Path.join(public_path, "*.md") |> Path.wildcard() do
  front_matter_yaml =
    current_filename
    |> File.read!()
    |> String.split("\n---\n")
    |> Enum.fetch!(0)

  parsed_front_matter = YamlElixir.read_from_string!(front_matter_yaml)
  id = Map.fetch!(parsed_front_matter, "id")
  title = Map.fetch!(parsed_front_matter, "title")
  updated_at = Map.fetch!(parsed_front_matter, "updated_at")
  extname = Path.extname(current_filename)

  new_filename =
    if id == "" or updated_at == "" do
      title_hash =
        title
        |> :erlang.md5()
        |> Base.encode16(case: :lower)
        |> binary_part(0, 3)

      Path.join(public_path, "draft-#{title_hash}#{extname}")
    else
      ymd =
        updated_at
        |> Timex.parse!("{ISO:Extended}")
        |> Timex.format!("%Y%m%d", :strftime)

      Path.join(public_path, "#{ymd}-#{id}#{extname}")
    end

  if current_filename != new_filename do
    if parsed_opts[:dry_run] do
      IO.puts(["dry run: ", current_filename, " -> ", new_filename])
    else
      File.rename!(current_filename, new_filename)
      IO.puts(["renamed: ", current_filename, " -> ", new_filename])
    end
  end
end
