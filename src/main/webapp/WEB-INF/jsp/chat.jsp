<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="portlet" uri="http://java.sun.com/portlet_2_0" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<portlet:defineObjects />

<portlet:renderURL var="backUrl" />

<portlet:resourceURL var="chatCssUrl" id="static">
  <portlet:param name="path" value="/static/css/chat.css"/>
</portlet:resourceURL>

<portlet:resourceURL var="chatJsUrl" id="static">
  <portlet:param name="path" value="/static/js/chat.js"/>
</portlet:resourceURL>

<portlet:resourceURL var="ajaxTestUrl">
  <portlet:param name="action" value="ping"/>
</portlet:resourceURL>

<link rel="stylesheet" href="${chatCssUrl}" />

<div class="ws-root">
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
  window.__CHAT_PORTLET__ = {
    ns: "<portlet:namespace/>",
    ajaxTestUrl: "${ajaxTestUrl}"
  };
</script>
<script src="${chatJsUrl}"></script>
