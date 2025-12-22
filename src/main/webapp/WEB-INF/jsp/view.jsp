<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<portlet:defineObjects />

<div class="p-card">
  <div class="p-header">
    <h3>Simple MVC Portlet (JSP + JSR-286)</h3>
    <p class="p-sub">Compatível com Pluto e WebSphere Portal 9 (mantendo apenas Portlet 2.0 API).</p>
  </div>

  <c:if test="${not empty lastMessage}">
    <div class="p-alert">
      Última mensagem enviada (via Action): <strong><c:out value="${lastMessage}"/></strong>
    </div>
  </c:if>

  <portlet:actionURL var="sendActionUrl" />
  <form method="post" action="${sendActionUrl}" class="p-form">
    <label for="message">Mensagem:</label>
    <input id="message" name="message" type="text" placeholder="Digite algo..." />
    <button type="submit">Enviar (Action)</button>
  </form>

  <hr class="p-hr"/>

  <portlet:resourceURL var="pingUrl">
    <portlet:param name="action" value="ping" />
  </portlet:resourceURL>

  <div class="p-row">
    <button type="button" class="p-secondary" onclick="ping()">Ping (Resource JSON)</button>
    <span id="pingResult" class="p-mono"></span>
  </div>

  <p class="p-footnote">
    Dica: se você usar AJAX no portal, prefira sempre <code>serveResource()</code> + <code>&lt;portlet:resourceURL&gt;</code>.
  </p>
</div>

<link rel="stylesheet" href="<portlet:resourceURL id='static'><portlet:param name='path' value='/static/portlet.css'/></portlet:resourceURL>"/>

<script>
  async function ping() {
    const el = document.getElementById('pingResult');
    el.textContent = '...';
    try {
      const res = await fetch('${pingUrl}', { credentials: 'same-origin' });
      const json = await res.json();
      el.textContent = JSON.stringify(json);
    } catch (e) {
      el.textContent = 'Erro: ' + (e && e.message ? e.message : e);
    }
  }
</script>
