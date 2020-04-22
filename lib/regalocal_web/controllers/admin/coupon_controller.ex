defmodule RegalocalWeb.Admin.CouponController do
  use RegalocalWeb, :controller
  use RegalocalWeb.Admin.BaseController

  alias Regalocal.Admin
  alias Regalocal.Admin.Coupon
  alias RegalocalWeb.Orders.{Mailer, GiftIsReadyEmail}

  def index(conn, _params) do
    coupons = Admin.list_coupons(conn.assigns[:business_id])

    conn
    |> render("index.html", coupons: coupons)
  end

  def new(conn, _params) do
    changeset = Admin.change_coupon(%Coupon{})

    conn
    |> render("new.html", changeset: changeset)
  end

  def create(conn, %{"coupon" => coupon_params}) do
    params =
      Map.merge(coupon_params, %{
        "business_id" => conn.assigns[:business_id],
        "status" => :published
      })

    case Admin.create_coupon(params) do
      {:ok, coupon} ->
        conn
        |> put_flash(:info, gettext("Coupon created successfully."))
        |> redirect(to: Routes.admin_coupon_path(conn, :show, coupon))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end

  def publish(conn, %{"id" => id}) do
    coupon = Admin.get_coupon!(conn.assigns[:business_id], id)

    case Admin.publish_coupon!(coupon) do
      {:ok, _} ->
        conn
        |> put_flash(:info, gettext("Coupon published successfully."))
        |> redirect(to: Routes.admin_coupon_path(conn, :index))

      {:error, :unpublishable} ->
        conn
        |> put_flash(
          :error,
          gettext("El cupó no està en estat d'esborrany")
        )
        |> redirect(to: Routes.admin_coupon_path(conn, :index))

      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:error, gettext("Coupon could not be published."))
        |> redirect(to: Routes.admin_coupon_path(conn, :index))
    end
  end

  def unpublish(conn, %{"id" => id}) do
    coupon = Admin.get_coupon!(conn.assigns[:business_id], id)

    case Admin.unpublish_coupon!(coupon) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Coupon unpublished successfully.")
        |> redirect(to: Routes.admin_coupon_path(conn, :index))

      {:error, :has_orders} ->
        conn
        |> put_flash(
          :error,
          "El cupó ja ha sigut comprat almenys un cop, per tant no es pot despublicar. Si vols que ningú més el pugui comprar, arxiva'l."
        )
        |> redirect(to: Routes.admin_coupon_path(conn, :index))

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "Coupon could not be unpublished.")
        |> redirect(to: Routes.admin_coupon_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    coupon = Admin.get_coupon!(conn.assigns[:business_id], id)
    orders = Admin.get_gifts!(coupon.id)

    conn
    |> render("show.html", coupon: coupon, orders: orders)
  end

  def edit(conn, %{"id" => id}) do
    coupon = Admin.get_coupon!(conn.assigns[:business_id], id)
    changeset = Admin.change_coupon(coupon)

    conn
    |> render("edit.html", coupon: coupon, changeset: changeset)
  end

  def update(conn, %{"id" => id, "coupon" => coupon_params}) do
    coupon = Admin.get_coupon!(conn.assigns[:business_id], id)

    case Admin.update_coupon(coupon, coupon_params) do
      {:ok, coupon} ->
        conn
        |> put_flash(:info, "Coupon updated successfully.")
        |> redirect(to: Routes.admin_coupon_path(conn, :show, coupon))

      {:error, :has_orders} ->
        conn
        |> put_flash(
          :error,
          "El cupó ja ha sigut comprat almenys un cop, per tant no es pot modificar. Si vols canviar les condicions, arxiva'l i crea'n un de nou."
        )
        |> redirect(to: Routes.admin_coupon_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render("edit.html", coupon: coupon, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    coupon = Admin.get_coupon!(conn.assigns[:business_id], id)
    {:ok, _coupon} = Admin.delete_coupon(coupon)

    conn
    |> put_flash(:info, "El cupó s'ha eliminat correctament.")
    |> redirect(to: Routes.admin_coupon_path(conn, :index))
  end

  def archive(conn, %{"id" => id}) do
    coupon = Admin.get_coupon!(conn.assigns[:business_id], id)
    {:ok, _coupon} = Admin.archive_coupon(coupon)

    conn
    |> put_flash(:info, "El cupó s'ha arxivat correctament.")
    |> redirect(to: Routes.admin_coupon_path(conn, :index))
  end

  def activate(conn, %{"id" => id}) do
    business = Admin.get_business!(conn.assigns[:business_id])
    coupon = Admin.get_coupon!(business.id, id)
    {:ok, _coupon} = Admin.activate_coupon(coupon)
    gifts = Admin.get_gifts!(coupon.id)

    Enum.each(gifts, fn gift ->
      GiftIsReadyEmail.generate(gift, business)
      |> Mailer.deliver()
    end)

    conn
    |> put_flash(:info, "El cupó s'ha activat correctament.")
    |> redirect(to: Routes.admin_coupon_path(conn, :index))
  end
end
