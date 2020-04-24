defmodule RegalocalWeb.PublicLayoutHelpers do
  import Phoenix.HTML.Tag

  def container([class: class], do: content) do
    container(:wide) do
      content_tag(:div, content,
        class: "mx-auto max-w-screen-xl relative p-4 sm:p-6 lg:p-8 #{class}"
      )
    end
  end

  def container(type, do: content), do: container(type, [class: ""], do: content)

  def container(do: content), do: container([class: ""], do: content)

  def container(:wide, [class: class], do: content) do
    content_tag(:div, content, class: "bg-white border-t border-primary-100 #{class}")
  end

  def container(:padded, [class: class], do: content) do
    container do
      content_tag(:div, content, class: "max-w-screen-md mx-auto py-16 lg:py-24 #{class}")
    end
  end
end
