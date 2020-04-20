defmodule RegalocalWeb.Router do
  use RegalocalWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  import Phoenix.LiveDashboard.Router
  import Plug.BasicAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug RegalocalWeb.Plugs.Veil.Business
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RegalocalWeb do
    pipe_through :browser
    get "/business/:id", BusinessController, :show
    get "/coupons/:id/gifts/new", GiftController, :new
    post "/coupons/:id/gifts", GiftController, :create
    get "/gifts/:reference/payment_sent", GiftController, :payment_sent, as: :payment_sent

    resources("/faq", FaqController, only: [:index])
    get "/search", SearchController, :index
    get "/", PageController, :index
    get "/terms", PageController, :terms
    get "/privacy", PageController, :privacy
    get "/cookies", PageController, :cookies
    get "/about", PageController, :about
  end

  pipeline :system_admins do
    plug :auth

    defp auth(conn, _opts) do
      [username: username, password: password] = Application.get_env(:regalocal, :basic_auth)

      with {request_username, request_password} <- Plug.BasicAuth.parse_basic_auth(conn),
           valid_username? = Plug.Crypto.secure_compare(username, request_username),
           valid_password? = Plug.Crypto.secure_compare(password, request_password),
           true <- valid_username? and valid_password? do
        conn
      else
        _ -> conn |> Plug.BasicAuth.request_basic_auth() |> halt()
      end
    end
  end

  scope "/" do
    pipe_through [:browser, :system_admins]
    live_dashboard "/dashboard", metrics: RegalocalWeb.Telemetry
  end

  # Other scopes may use custom stacks.
  # scope "/api", RegalocalWeb do
  #   pipe_through :api
  # end

  # Default Routes for Veil
  scope "/auth", RegalocalWeb.Veil do
    pipe_through(:browser)

    post("/businesses", BusinessController, :create, as: :veil_business)
    get("/businesses/new", BusinessController, :new, as: :veil_business)

    get("/sessions/new/:request_id", SessionController, :create)
    delete("/sessions/:session_id", SessionController, :delete)
  end

  scope "/admin", RegalocalWeb.Admin, as: :admin do
    pipe_through([:browser, RegalocalWeb.Plugs.Veil.Authenticate, RegalocalWeb.Plugs.Acceptance])

    get("/", DashboardController, :show)
    get("/orders", OrderController, :index)
    get("/orders/search", OrderController, :search)
    get("/orders/:id", OrderController, :show)
    put("/orders/:id/payment_received", OrderController, :payment_received, as: :payment_received)
    put("/orders/:id/redeem", OrderController, :redeem, as: :order_redeemed)
    get("/business", BusinessController, :show)
    resources("/coupons", CouponController)
    put("/coupons/:id/publish", CouponController, :publish, as: :publish_coupon)
    put("/coupons/:id/unpublish", CouponController, :unpublish, as: :unpublish_coupon)
    put("/coupons/:id/archive", CouponController, :archive, as: :archive_coupon)
    put("/coupons/:id/activate", CouponController, :activate, as: :activate_coupon)
  end

  scope "/admin", RegalocalWeb.Admin, as: :admin do
    pipe_through([:browser, RegalocalWeb.Plugs.Veil.Authenticate])

    get("/business/edit", BusinessController, :edit)
    put("/business", BusinessController, :update)
  end

  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through [:browser]

      forward "/mailbox", Plug.Swoosh.MailboxPreview, base_path: "/dev/mailbox"
    end
  end
end
