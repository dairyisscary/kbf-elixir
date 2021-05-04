defmodule KbfWeb.HTML do
  def attrs_with_class_default(opts, ""), do: opts

  def attrs_with_class_default(opts, nil), do: opts

  def attrs_with_class_default(opts, default) when is_map(opts) do
    opts
    |> Map.update(:class, default, &"#{&1} #{default}")
  end

  def attrs_with_class_default(opts, default) when is_list(opts) do
    opts
    |> Keyword.update(:class, default, &"#{&1} #{default}")
  end

  @doc false
  defmacro __using__(_) do
    quote do
      import Phoenix.HTML

      import Phoenix.HTML.Form,
        except: [
          number_input: 2,
          number_input: 3,
          text_input: 2,
          text_input: 3,
          textarea: 2,
          textarea: 3,
          date_input: 2,
          date_input: 3
        ]

      import Phoenix.HTML.Link
      import Phoenix.HTML.Tag
      import Phoenix.HTML.Format
      import KbfWeb.HTML
      import KbfWeb.HTML.Form
    end
  end
end
