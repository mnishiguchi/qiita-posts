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
# ## Notes
#
# - Ideally we want to use creation date for naming files but currently only
# the updated_at timestamp is available.
#

Mix.install([:yaml_front_matter, :timex])

{parsed_opts, _} =
  System.argv()
  |> OptionParser.parse!(
    strict: [dry_run: :boolean],
    aliases: [n: :dry_run]
  )

public_path = Path.join(File.cwd!(), "public")

should_rename_fun = fn current_filename ->
  filename_contains_timestamp = current_filename =~ ~r/\d{8}-/
  filename_contains_draft = current_filename =~ ~r/draft-/

  not filename_contains_timestamp and not filename_contains_draft
end

draft_id_fun = fn title ->
  title_hash =
    title
    |> :erlang.md5()
    |> Base.encode16(case: :lower)
    |> binary_part(0, 3)

  "_draft-#{title_hash}"
end

new_filename_fun = fn
  "", "_draft_" <> <<_::binary>> = draft_id, extname ->
    Path.join(public_path, "#{draft_id}#{extname}")

  updated_at, id, extname ->
    ymd =
      updated_at
      |> Timex.parse!("{ISO:Extended}")
      |> Timex.format!("%Y%m%d", :strftime)

    Path.join(public_path, "#{ymd}-#{id}#{extname}")
end

for current_filename <- Path.join(public_path, "*.md") |> Path.wildcard() do
  {parsed_front_matter, _body} = YamlFrontMatter.parse_file!(current_filename)
  updated_at = parsed_front_matter["updated_at"] || ""
  title = parsed_front_matter["title"] || ""
  id = parsed_front_matter["id"] || draft_id_fun.(title)
  extname = Path.extname(current_filename)

  new_filename =
    if should_rename_fun.(current_filename) do
      new_filename_fun.(updated_at, id, extname)
    else
      current_filename
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
