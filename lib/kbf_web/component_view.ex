defmodule KbfWeb.ComponentView do
  use KbfWeb, :view

  def category_pill_opts(pill_opts) do
    pill_opts
    |> attrs_with_class_default("space-x-1 rounded-sm px-2 py-1 text-sm")
    |> attrs_with_class_default(if(pill_opts[:phx_click], do: "cursor-pointer"))
    |> attrs_with_class_default(if(pill_opts[:faded], do: "opacity-50"))
    |> attrs_with_class_default(KbfWeb.Category.color_classes_for(pill_opts[:category]))
    |> Map.drop([:category, :faded])
    |> Map.to_list()
  end

  def table_tr_opts(row_opts) do
    row_opts
    |> attrs_with_class_default("transition-all hover:bg-gray-100 hover:shadow-lg")
    |> Keyword.delete(:do)
  end

  def button_attrs(opts) when is_map(opts) do
    opts
    |> Map.put_new(:type, "button")
    |> attrs_with_class_default(button_classes(opts[:button_style]))
    |> Map.drop([:do, :button_style])
    |> Map.to_list()
  end

  defp button_classes(style) do
    "inline-flex items-center justify-center rounded-md border shadow-sm px-4 py-2 transition-all hover:bg-gray-100 hover:shadow-md disabled:opacity-50 " <>
      button_style_classes(style)
  end

  defp button_style_classes(:confirm),
    do: "border-transparent bg-purple-600 text-gray-100 hover:bg-purple-700"

  defp button_style_classes(:warning),
    do: "border-transparent bg-red-600 text-gray-100 hover:bg-red-700"

  defp button_style_classes(_style), do: "bg-white border-gray-300 hover:bg-gray-50"
end
