defmodule RegalocalWeb.GiftController do
  use RegalocalWeb, :controller

  alias Regalocal.Orders
  alias Regalocal.Orders.Gift
  alias RegalocalWeb.Orders.{Mailer, AfterOrderEmail, GiftEmail, PaymentSentEmail}

  def new(conn, %{"id" => coupon_id}) do
    coupon = Orders.get_coupon!(coupon_id)
    business = Orders.get_business!(coupon.business_id)
    changeset = Orders.change_gift(%Gift{})
    render(conn, "new.html", changeset: changeset, coupon: coupon, business: business)
  end

  def create(conn, %{"id" => coupon_id, "gift" => gift_params}) do
    coupon = Orders.get_coupon!(coupon_id)
    business = Orders.get_business!(coupon.business_id)

    params =
      if is_nil(coupon.terms) do
        gift_params |> Map.put("accepted_coupon_terms", true)
      else
        gift_params
      end
      |> Map.merge(%{
        "coupon_id" => coupon_id,
        "business_id" => coupon.business_id,
        "amount" => coupon.amount,
        "value" => coupon.value,
        "status" => :pending_payment,
        "reference" => Orders.generate_unique_reference()
      })

    case Orders.create_gift(params) do
      {:ok, gift} ->
        send_emails(conn, gift, business)

        conn
        |> render("thanks.html", gift: gift)

      {:error, %Ecto.Changeset{} = changeset} ->
        business = Orders.get_business!(coupon.business_id)
        render(conn, "new.html", changeset: changeset, coupon: coupon, business: business)
    end
  end

  def generate_token(gift) do
    salt = RegalocalWeb.Endpoint.config(:secret_key_base)
    Phoenix.Token.sign(RegalocalWeb.Endpoint, salt, gift.reference)
  end

  def payment_sent(conn, %{"reference" => gift_reference, "token" => token}) do
    salt = RegalocalWeb.Endpoint.config(:secret_key_base)
    {:ok, _} = Phoenix.Token.verify(RegalocalWeb.Endpoint, salt, token, max_age: :infinity)

    gift = Orders.get_gift_by_reference!(gift_reference)
    business = Orders.get_business!(gift.business_id)

    if gift && gift.status == :pending_payment do
      case Orders.update_gift(gift, %{
             "status" => :paid,
             "accepted_gift_terms" => true,
             "accepted_coupon_terms" => true
           }) do
        {:ok, gift} ->
          PaymentSentEmail.generate(conn, gift, business)
          |> Mailer.deliver()

          conn
          |> put_flash(
            :info,
            gettext("Moltes gràcies per confirmar el pagament. Hem notificat al comerç.")
          )
          |> redirect(to: Routes.page_path(conn, :index))

        {:error, %Ecto.Changeset{} = _changeset} ->
          conn
          |> redirect(to: Routes.page_path(conn, :index))
      end
    else
      conn
      |> put_status(:not_found)
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def send_emails(conn, gift, business) do
    AfterOrderEmail.generate(conn, gift, business, generate_token(gift))
    |> Mailer.deliver()

    GiftEmail.generate(gift, business)
    |> Mailer.deliver()
  end
end
