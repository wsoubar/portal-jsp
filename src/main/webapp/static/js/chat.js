
(function () {
  // Pegamos config que o JSP injeta no window antes de carregar este arquivo
  const cfg = window.__CHAT_PORTLET__;
  if (!cfg || !cfg.ns) {
    console.error("[CHAT] Config não encontrada (window.__CHAT_PORTLET__)");
    return;
  }

  document.addEventListener("DOMContentLoaded", async function () {
    const cfg = window.__CHAT_PORTLET__;

    if (!cfg || !cfg.ajaxTestUrl) {
      console.error("[AJAX] ajaxTestUrl não encontrado");
      return;
    }

    try {
      console.log("[AJAX] Chamando ping automaticamente...");

      const resp = await fetch(cfg.ajaxTestUrl, {
        method: "GET",
        credentials: "same-origin"
      });

      if (!resp.ok) {
        throw new Error("HTTP " + resp.status);
      }

      const data = await resp.json();

      console.log("[AJAX] Resposta automática:", data);

      // Exemplo de uso prático:
      // if (data.message === "pong") { ... }

    } catch (e) {
      console.error("[AJAX] Erro na chamada automática:", e);
    }
  });


  const NS = cfg.ns;
  let ws = null;

  const statusText = document.getElementById(NS + "statusText");
  const logDiv = document.getElementById(NS + "log");
  const msgInput = document.getElementById(NS + "msgInput");
  const urlInput = document.getElementById(NS + "urlInput");

  const btnConnect = document.getElementById(NS + "btnConnect");
  const btnDisconnect = document.getElementById(NS + "btnDisconnect");
  const btnSend = document.getElementById(NS + "btnSend");

  if (!statusText || !logDiv || !msgInput || !urlInput || !btnConnect || !btnDisconnect || !btnSend) {
    console.error("[CHAT] Elementos não encontrados. NS=", NS);
    return;
  }

  function setStatus(status) { statusText.textContent = status; }

  function log(msg, cssClass = "system") {
    const div = document.createElement("div");
    div.textContent = msg;
    div.className = cssClass;
    logDiv.appendChild(div);
    logDiv.scrollTop = logDiv.scrollHeight;
  }

  function conectar() {
    if (ws && ws.readyState === WebSocket.OPEN) {
      log("[INFO] WebSocket já está conectado", "system");
      return;
    }

    const url = (urlInput.value || "").trim();
    if (!url || !(url.startsWith("wss://") || url.startsWith("ws://"))) {
      log("[ERRO] URL inválida. Use ws:// ou wss://", "error");
      return;
    }

    log("[INFO] Conectando em " + url, "system");
    setStatus("connecting");

    ws = new WebSocket(url);

    ws.addEventListener("open", () => {
      setStatus("open");
      log("[OPENED] Conectado ao WebSocket", "system");
    });

    ws.addEventListener("message", (event) => {
      setStatus("message");
      log("[RECEBIDO] " + event.data, "received");
    });

    ws.addEventListener("close", (event) => {
      setStatus("close");
      log(`[CLOSE] code=${event.code}, reason=${event.reason || "sem motivo"}`, "system");
      ws = null;
    });

    ws.addEventListener("error", (event) => {
      setStatus("error");
      log("[ERROR] Erro no WebSocket", "error");
      console.log("[WS] Erro no WebSocket", event);
    });
  }

  function desconectar() {
    if (ws) {
      log("[INFO] Desconectando...", "system");
      ws.close(1000, "Desconectado pelo cliente");
    } else {
      log("[INFO] WebSocket não está conectado", "system");
    }
  }

  function enviar() {
    const msg = (msgInput.value || "").trim();
    if (!msg) return;

    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(msg);
      log("[ENVIADO] " + msg, "sent");
      msgInput.value = "";
      msgInput.focus();
    } else {
      log("[ERRO] WebSocket não está conectado", "error");
    }
  }

  btnConnect.addEventListener("click", conectar);
  btnDisconnect.addEventListener("click", desconectar);
  btnSend.addEventListener("click", enviar);

  msgInput.addEventListener("keydown", (e) => {
    if (e.key === "Enter") enviar();
  });

})();
