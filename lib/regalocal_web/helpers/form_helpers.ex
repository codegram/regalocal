defmodule RegalocalWeb.FormHelpers do
  use Phoenix.Template, root: "lib/regalocal_web/templates/helpers/form"
  alias Phoenix.HTML
  import RegalocalWeb.ErrorHelpers
  import RegalocalWeb.Gettext

  def section(do: content) do
    HTML.Tag.content_tag(:div, content, class: "pb-6")
  end

  def section(title, subtitle, do: content) do
    section do
      [
        section_title(title, subtitle),
        controls(do: content)
      ]
    end
  end

  def section(title, do: content) do
    section(title, nil, do: content)
  end

  def controls(do: content) do
    HTML.Tag.content_tag(:div, content, class: "mt-6 sm:mt-5")
  end

  def control(form, name, label, options \\ [], content) do
    defaults = [hint: nil]
    options = Keyword.merge(defaults, options)

    HTML.Tag.content_tag :div,
      class:
        "sm:grid sm:grid-cols-3 sm:gap-4 sm:items-start sm:border-t sm:border-gray-200 sm:pt-5 pb-5" do
      [
        HTML.Form.label(form, name, label,
          class: "block text-sm font-medium leading-5 text-gray-700 sm:mt-px sm:pt-2"
        ),
        HTML.Tag.content_tag :div, class: "mt-1 sm:mt-0 sm:col-span-2" do
          [
            HTML.Tag.content_tag(:div, apply(content, [form, name]),
              class: "mt-1 sm:mt-0 sm:col-span-2"
            ),
            hint_for(options[:hint]),
            error_tag(form, name)
          ]
        end
      ]
    end
  end

  def section_title(title, subtitle) do
    HTML.Tag.content_tag :div do
      [
        HTML.Tag.content_tag(:h3, title, class: "text-lg leading-6 font-medium text-gray-900"),
        if(subtitle,
          do:
            HTML.Tag.content_tag(:p, subtitle,
              class: "mt-1 max-w-2xl text-sm leading-5 text-gray-500"
            ),
          else: []
        )
      ]
    end
  end

  def text_input(form, field, options \\ []) do
    HTML.Form.text_input(
      form,
      field,
      [
        class:
          "max-w-lg form-input block w-full transition duration-150 ease-in-out sm:text-sm sm:leading-5"
      ] ++ options
    )
  end

  def prefixed_text_input(form, field, prefix, _options \\ []) do
    HTML.Tag.content_tag :div, class: "mt-1 flex rounded-md shadow-sm max-w-lg" do
      [
        HTML.Tag.content_tag(:span, prefix,
          class:
            "inline-flex items-center px-3 rounded-l-md border border-r-0 border-gray-300 bg-gray-50 text-gray-500 sm:text-sm"
        ),
        HTML.Form.text_input(form, field,
          class:
            "flex-1 form-input block w-full rounded-none rounded-r-md transition duration-150 ease-in-out sm:text-sm sm:leading-5"
        )
      ]
    end
  end

  def textarea(form, field, options \\ []) do
    HTML.Tag.content_tag :div, class: "max-w-lg flex rounded-md shadow-sm" do
      HTML.Form.textarea(
        form,
        field,
        [
          class:
            "form-textarea block w-full transition duration-150 ease-in-out sm:text-sm sm:leading-5",
          rows: 5
        ] ++ options
      )
    end
  end

  def select(form, field, items, options \\ []) do
    HTML.Tag.content_tag :div, class: "max-w-lg flex rounded-md shadow-sm" do
      HTML.Form.select(
        form,
        field,
        items,
        [
          class:
            "block form-select w-full transition duration-150 ease-in-out sm:text-sm sm:leading-5"
        ] ++ options
      )
    end
  end

  def currency_input(form, field, _items, options \\ []) do
    HTML.Tag.content_tag :div, class: "relative max-w-xs rounded-md shadow-sm" do
      [
        HTML.Form.text_input(
          form,
          field,
          [
            class:
              "max-w-lg form-input block w-full transition duration-150 ease-in-out sm:text-sm sm:leading-5"
          ] ++ options
        ),
        HTML.Tag.content_tag :div,
          class: "absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none" do
          HTML.Tag.content_tag(:span, "EUR", class: "text-gray-500 sm:text-sm sm:leading-5")
        end
      ]
    end
  end

  def buttons(submit_label) do
    HTML.Tag.content_tag :div,
      class:
        "sm:grid sm:grid-cols-3 sm:gap-4 sm:items-start sm:border-t sm:border-gray-200 sm:pt-5 pb-5" do
      [
        HTML.Tag.content_tag(:div, ""),
        HTML.Tag.content_tag :div, class: "flex justify-end sm:col-span-2 max-w-lg" do
          HTML.Tag.content_tag :span, class: "ml-3 inline-flex rounded-md shadow-sm" do
            HTML.Tag.content_tag(:button, submit_label, type: "Submit")
          end
        end
      ]
    end
  end

  def errors(%{action: action}) when action != nil do
    render_template("errors.html", %{})
  end

  def errors(_), do: []

  defp hint_for(nil), do: []

  defp hint_for(hint) do
    HTML.Tag.content_tag(:p, hint, class: "mt-2 text-sm text-gray-500 max-w-lg")
  end
end
