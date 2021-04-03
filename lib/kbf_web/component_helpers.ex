defmodule KbfWeb.ComponentHelpers do
  def component(template, assigns) do
    KbfWeb.ComponentView.render(template, assigns)
  end

  def component(template, assigns, do: block) do
    KbfWeb.ComponentView.render(template, Keyword.merge(assigns, do: block))
  end
end
