defmodule KbfWeb.HTML.Form do
  import Phoenix.HTML, only: [sigil_E: 2]

  def number_input(form, field, opts \\ []) do
    a11y_opts =
      opts
      |> add_default_attributes()
      |> Keyword.put_new(:inputmode, "numeric")
      |> Keyword.put_new(:pattern, "-?[0-9]+(\.[0-9]*)?")

    Phoenix.HTML.Form.text_input(form, field, a11y_opts)
  end

  def text_input(form, field, opts \\ []) do
    Phoenix.HTML.Form.text_input(form, field, add_default_attributes(opts))
  end

  def textarea(form, field, opts \\ []) do
    Phoenix.HTML.Form.textarea(form, field, add_default_attributes(opts))
  end

  def date_input(form, field, opts \\ []) do
    Phoenix.HTML.Form.date_input(form, field, add_default_attributes(opts))
  end

  def radio_button_with_label(form, field, value, opts \\ [], do: block) do
    Phoenix.HTML.Form.label class: "cursor-pointer inline-flex items-center space-x-2" do
      ~E"""
        <%= Phoenix.HTML.Form.radio_button(form, field, value, opts) %>
        <span><%= block %></span>
      """
    end
  end

  def category_input(all_categories, selected, opts_fn) do
    Phoenix.HTML.Tag.content_tag :div, class: "flex flex-wrap gap-2" do
      for category <- all_categories do
        KbfWeb.ComponentHelpers.html_component(
          "category_pill.html",
          opts_fn.(
            category: category,
            phx_value_category_id: category.id,
            faded: !selected[category.id]
          )
        )
      end
    end
  end

  def error_tags(form, field) do
    feedback_for = Phoenix.HTML.Form.input_name(form, field)

    form.errors
    |> Keyword.put_new(field, {"", nil})
    |> Keyword.get_values(field)
    |> Enum.map(fn {message, _} ->
      Phoenix.HTML.Tag.content_tag(:span, message,
        class: "kbf-feedback text-sm mt-2 text-red-600",
        phx_feedback_for: feedback_for
      )
    end)
  end

  defp add_default_attributes(attrs) do
    attrs
    |> add_input_classes()
    |> Keyword.put_new(:autocomplete, "off")
  end

  defp add_input_classes(attrs) do
    KbfWeb.HTML.attrs_with_class_default(
      attrs,
      "transition-colors w-full shadow-sm border-gray-300 rounded-md focus:border-purple-700"
    )
  end
end
