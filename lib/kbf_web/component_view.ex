defmodule KbfWeb.ComponentView do
  use KbfWeb, :view

  @tr_row_classes "transition-all hover:bg-gray-100 hover:shadow-lg"

  def table_tr_opts(row_opts) do
    row_opts
    |> Keyword.update(:class, @tr_row_classes, &"#{&1} #{@tr_row_classes}")
    |> Keyword.delete(:do)
  end

  def button_attrs(opts) when is_map(opts) do
    classes = button_classes(opts[:button_style])

    opts
    |> Map.put_new(:type, "button")
    |> Map.update(:class, classes, &"#{&1} #{classes}")
    |> Map.drop([:do, :button_style])
    |> Map.to_list()
  end

  defp button_classes(style) do
    "inline-flex items-center justify-center rounded-md border shadow-sm px-4 py-2 transition-all hover:bg-gray-100 hover:shadow-md disabled:opacity-50 " <>
      button_style_classes(style)
  end

  defp button_style_classes(:confirm),
    do: "border-transparent bg-purple-600 text-white hover:bg-purple-700"

  defp button_style_classes(_style), do: "bg-white border-gray-300 hover:bg-gray-50"
end
