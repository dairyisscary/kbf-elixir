defmodule KbfWeb.ComponentHelpers do
  def html_component(template) do
    KbfWeb.ComponentView.render(template, [])
  end

  def html_component(template, assigns) do
    KbfWeb.ComponentView.render(template, assigns)
  end

  def html_component(template, assigns, do: block) do
    KbfWeb.ComponentView.render(template, Keyword.merge(assigns, do: block))
  end
end
