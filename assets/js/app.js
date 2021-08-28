import "../css/app.scss";
import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import Topbar from "topbar";

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
window.kbfLiveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
});

Topbar.config({
  barColors: { 0: "#4F46E5", 0.8: "#059669" },
  shadowColor: "rgba(0, 0, 0, 0.25)",
});
window.addEventListener("phx:page-loading-start", () => Topbar.show());
window.addEventListener("phx:page-loading-stop", () => Topbar.hide());

window.kbfLiveSocket.connect();
