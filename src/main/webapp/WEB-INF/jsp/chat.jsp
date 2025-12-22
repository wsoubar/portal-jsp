<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="portlet" uri="http://java.sun.com/portlet_2_0" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<portlet:defineObjects />

<style>
  :root {
    --bg: #f4f6f9;
    --card: #ffffff;
    --primary: #2563eb;
    --success: #16a34a;
    --danger: #dc2626;
    --warning: #ca8a04;
    --muted: #6b7280;
    --border: #e5e7eb;
  }

  .ws-<portlet:namespace/> {
    font-family: Arial, sans-serif;
    background: var(--bg);
    margin: 0;
    padding: 18px;
  }

  .ws-<portlet:namespace/> h2 {
    margin-top: 0;
    color: #111827;
  }

  .ws-<portlet:namespace/> .container {
    max-width: 900px;
    margin: auto;
    background: var(--card);
    border-radius: 8px;
    padding: 20px;
    box-shadow: 0 10px 25px rgba(0,0,0,0.05);
  }

  .ws-<portlet:namespace/> .status {
    font-weight: bold;
    margin-bottom: 15px;
    color: var(--muted);
  }

  .ws-<portlet:namespace/> .statusText {
    padding: 3px 8px;
    border-radius: 4px;
    background: #eef2ff;
    color: var(--primary);
  }

  .ws-<portlet:namespace/> .log {
    border: 1px solid var(--border);
    height: 300px;
    padding: 10px;
    overflow-y: auto;
    background: #f9fafb;
    font-family: monospace;
    font-size: 13px;
    border-radius: 6px;
  }

  .ws-<portlet:namespace/> .sent { color: var(--primary); }
  .ws-<portlet:namespace/> .received { color: var(--success); }
  .ws-<portlet:namespace/> .system { color: var(--muted); }
  .ws-<portlet:namespace/> .error { color: var(--danger); }

  .ws-<portlet:namespace/> .controls,
  .ws-<portlet:namespace/> .input-area {
    margin-top: 12px;
    display: flex;
    gap: 8px;
  }

  .ws-<portlet:namespace/> input[type="text"] {
    flex: 1;
    padding: 8px 10px;
    border-radius: 6px;
    border: 1px solid var(--border);
    font-size: 14px;
  }

  .ws-<portlet:namespace/> input[type="text"]:focus {
    outline: none;
    border-color: var(--primary);
    box-shadow: 0 0 0 2px rgba(37,99,235,0.1);
  }

  .ws-<portlet:namespace/> button {
    padding: 8px 14px;
    border-radius: 6px;
    border: none;
    font-size: 14px;
    cursor: pointer;
    background: var(--primary);
    color: white;
    transition: background 0.2s ease;
  }

  .ws-<portlet:namespace/> button:hover {
    background: #1d4ed8;
  }

  .ws-<portlet:namespace/> .btn-disconnect {
    background: var(--danger);
  }
  .ws-<portlet:namespace/> .btn-disconnect:hover {
    background: #b91c1c;
  }
</style>

<portlet:renderURL var="backUrl" />

<div class="ws-<portlet:namespace/>">
  <div class="container">

    <c:choose>
      <c:when test="${empty userName}">
        <div style="padding:10px 12px; border:1px solid var(--border); border-radius:8px; margin-bottom:12px;">
          <strong>Você ainda não informou seus dados.</strong>
          <div style="margin-top:6px;">
            <a href="${backUrl}"><button type="button">Voltar para Identificação</button></a>
          </div>
        </div>
      </c:when>
      <c:otherwise>
        <div style="padding:10px 12px; border:1px solid var(--border); border-radius:8px; margin-bottom:12px; background:#ffffff;">
          <div><strong>Nome:</strong> <c:out value="${userName}"/></div>
          <div><strong>Telefone:</strong> <c:out value="${userPhone}"/></div>
          <div><strong>Termos aceitos:</strong> <c:out value="${acceptedTerms}"/></div>
        </div>
      </c:otherwise>
    </c:choose>

    <div style="display:flex; justify-content:space-between; align-items:center; gap:10px;">
      <h2 style="margin:0;">WebSocket – Cliente Simples</h2>
      <a href="${backUrl}"><button type="button">Voltar</button></a>
    </div>

    <div class="status">
      Status: <span id="<portlet:namespace/>statusText" class="statusText">desconectado</span>
    </div>

    <div class="controls">
      <input
        type="text"
        id="<portlet:namespace/>urlInput"
        placeholder="wss://"
        value="wss://echo.websocket.org"
      />
      <button type="button" id="<portlet:namespace/>btnConnect">Conectar</button>
      <button type="button" class="btn-disconnect" id="<portlet:namespace/>btnDisconnect">Desconectar</button>
    </div>

    <div id="<portlet:namespace/>log" class="log"></div>

    <div class="input-area">
      <input type="text" id="<portlet:namespace/>msgInput" placeholder="Digite a mensagem..." />
      <button type="button" id="<portlet:namespace/>btnSend">Enviar</button>
    </div>

  </div>
</div>

<script>
(function () {
  const NS = "<portlet:namespace/>";
  let ws = null;

  const statusText = document.getElementById(NS + "statusText");
  const logDiv = document.getElementById(NS + "log");
  const msgInput = document.getElementById(NS + "msgInput");
  const urlInput = document.getElementById(NS + "urlInput");

  const btnConnect = document.getElementById(NS + "btnConnect");
  const btnDisconnect = document.getElementById(NS + "btnDisconnect");
  const btnSend = document.getElementById(NS + "btnSend");

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
      log("[OPEN] Conectado ao WebSocket", "system");
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
</script>
