defmodule RegalocalWeb.Veil.LoginEmail do
  use Phoenix.Swoosh, view: RegalocalWeb.Veil.EmailView, layout: {RegalocalWeb.LayoutView, :email}

  import RegalocalWeb.PremailHelper
  import RegalocalWeb.Gettext

  @doc """
  Generates an email using the login template.
  """
  def generate(email, url) do
    site = Application.get_env(:veil, :site_name)

    new()
    |> to(email)
    |> from(from_email())
    |> subject(gettext("🤗 Et donem la benvinguda a %{site_name}!", site_name: site))
    |> render_body("login.html", %{url: url, site_name: site})
    |> premail
  end

  defp from_email do
    {Application.get_env(:veil, :email_from_name),
     Application.get_env(:veil, :email_from_address)}
  end
end
