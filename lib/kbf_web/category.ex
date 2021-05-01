defmodule KbfWeb.Category do
  use KbfWeb.HTML

  def color_classes_for(%Kbf.Category{color_code: color_code}), do: color_class_lookup(color_code)

  def all_bg_color_classes(opts_fn) do
    Kbf.Category.color_code_range()
    |> Enum.map(fn color_code ->
      bg_color_on_display(color_code, opts_fn.(color_code))
    end)
  end

  def bg_color_on_display(color_code, opts \\ []) do
    opts =
      opts
      |> attrs_with_class_default(color_class_lookup(color_code))
      |> attrs_with_class_default(
        "transition-colors inline-flex items-center justify-center rounded-full w-6 h-6"
      )

    content_tag(:span, Keyword.get(opts, :do, ""), Keyword.delete(opts, :do))
  end

  def sort_by_name(categories) do
    categories
    |> Enum.sort_by(& &1.name)
  end

  defp color_class_lookup(color_code) do
    case color_code do
      11 ->
        "bg-pink-600 text-gray-100"

      10 ->
        "bg-pink-300"

      9 ->
        "bg-purple-600 text-gray-100"

      8 ->
        "bg-purple-300"

      7 ->
        "bg-blue-600 text-gray-100"

      6 ->
        "bg-blue-300"

      5 ->
        "bg-red-600 text-gray-100"

      4 ->
        "bg-red-300"

      3 ->
        "bg-green-600 text-gray-100"

      2 ->
        "bg-green-300"

      1 ->
        "bg-yellow-600"

      _ ->
        "bg-yellow-300"
    end
  end
end
