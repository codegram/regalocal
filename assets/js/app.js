// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import "alpinejs"
// Import local files
//
// Local files can be imported directly using relative paths, for example:
import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket

import { geolocate } from "./geolocation"

window.geolocate = geolocate
