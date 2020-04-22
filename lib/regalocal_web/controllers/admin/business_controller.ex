defmodule RegalocalWeb.Admin.BusinessController do
  use RegalocalWeb, :controller
  use RegalocalWeb.Admin.BaseController

  alias Regalocal.Admin

  def edit(conn, _params) do
    business = current_business(conn)
    changeset = Admin.change_business(business)

    conn
    |> render("edit.html", business: business, changeset: changeset)
  end

  def update(conn, %{"business" => params}) do
    business = current_business(conn)

    new_params =
      if upload = params["photo"] do
        {:ok, %Cloudex.UploadedImage{public_id: photo_id}} = Cloudex.upload(upload.path)
        Map.put(params, "photo_id", photo_id)
      else
        params
      end

    case Admin.update_business(business, new_params) do
      {:ok, _business} ->
        conn
        |> put_flash(:info, gettext("Business updated successfully."))
        |> redirect(to: Routes.admin_dashboard_path(conn, :show))

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)

        conn
        |> render("edit.html", business: business, changeset: changeset)
    end
  end

  def delete(conn) do
    business = current_business(conn)
    {:ok, _business} = Admin.delete_business(business)

    conn
    |> put_flash(:info, gettext("Business deleted successfully."))
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
