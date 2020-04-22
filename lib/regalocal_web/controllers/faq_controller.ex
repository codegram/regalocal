defmodule RegalocalWeb.FaqController do
  use RegalocalWeb, :controller
  import Phoenix.HTML

  @items [
    %{
      question: gettext("No trobo un comerç que m'agradaria que hi fos. Què puc fer?"),
      answer:
        gettext(
          "En aquest cas, t'encoratgem a que et posis en contacte amb ells per a fer-los saber de Regalocal, especialment si estan en dificultats pel COVID-19. Entre tots i totes podem aportar el nostre granet de sorra."
        )
    },
    %{
      question: gettext("RegaLocal es queda comissió de cada transacció?"),
      answer:
        gettext(
          "No, Regalocal és un servei gratüit sense ànim de lucre. No apliquem cap mena de comissió ni tarifa de serveis. El pagament es fa directament al compte bancari o Bizum proporcionats pel comerç, i per tant, el destinatari rep l'import íntegre."
        )
    },
    %{
      question: gettext("Com a comprador, què és el que estic regalant?"),
      answer:
        gettext(
          "Els comerços que estàn donats d'alta posen a disposició teva uns cupons de cert valor que es podràn fer servir un cop el comerç indiqui que pot rebre clients. Quan compres un cupó, el comerç sempre et fa un petit descompte com a agraïment, i la persona a qui li regales el rep immediatament."
        )
    },
    %{
      question: gettext("Quins comerços es poden unir a Regalocal?"),
      answer:
        gettext(
          "Petits i mitjans comerços de cara al públic: restaurants, cafeteries, hostals, perruqueries, veterinaris, teatres, estudis de tatuatge, en general qualsevol empresa petita o mitjana que hagi hagut d'aturar o reduïr la seva activitat degut al COVID-19."
        )
    },
    %{
      question: gettext("Quines garanties sobre els cupons que regalo?"),
      answer:
        gettext(
          "Comprar un cupó pot comportar cert risc en cas de que el comerç faci fallida. En aquest cas, t'hauràs de posar en contacte directament amb el comerç per a negociar un possible reemborsament."
        )
    },
    %{
      question: gettext("Com puc obtenir un ticket o factura del meu regal?"),
      answer:
        gettext(
          "Posa't en contacte amb el comerç directament. Trobaràs les seves dades de contacte en el mail de compra."
        )
    },
    %{
      question: gettext("Com puc posar-me en contacte amb RegaLocal?"),
      answer:
        gettext(
          "Pots obrir un chat amb <a href=\"#\" @click.prevent=\"$crisp.push(['do', 'chat:open'])\"/>suport tècnic</a>, o bé enviar-nos un correu electrònic a <a href=\"mailto:regalocal@codegram.com\">regalocal@codegram.com</a>."
        )
        |> raw
    }
  ]

  def index(conn, _params) do
    conn
    |> assign(:items, @items)
    |> render("index.html")
  end
end
