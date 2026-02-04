<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<portlet:defineObjects />

<link rel="stylesheet" href="<portlet:resourceURL id='static'><portlet:param name='path' value='/static/portlet.css'/></portlet:resourceURL>"/>

<div class="p-card">
  <div class="p-header">
    <h3>Identificação</h3>
    <p class="p-sub">Informe seus dados para continuar para o chat.</p>
  </div>

  <c:if test="${not empty param.error}">
    <div class="p-alert p-alert-danger">
      <c:out value="${param.error}"/>
    </div>
  </c:if>

  <portlet:actionURL var="advanceUrl" />

  <form method="post" action="${advanceUrl}" class="p-form">

    <div class="p-field">
      <label for="<portlet:namespace/>name">Nome</label>
      <input
        id="<portlet:namespace/>name"
        name="name"
        type="text"
        placeholder="Seu nome"
        value="<c:out value='${empty param.prefillName ? (empty userName ? \"\" : userName) : param.prefillName}'/>"
        required
      />
    </div>

    <div class="p-field">
      <label for="<portlet:namespace/>phone">Telefone</label>
      <input
        id="<portlet:namespace/>phone"
        name="phone"
        type="text"
        placeholder="(DDD) 99999-9999"
        value="<c:out value='${empty param.prefillPhone ? (empty userPhone ? \"\" : userPhone) : param.prefillPhone}'/>"
        required
      />
    </div>

    <div class="p-field">
      <label class="p-check">
      </label>
        <input
          id="<portlet:namespace/>acceptTerms"
          name="acceptTerms"
          type="checkbox"
          <c:if test="${param.prefillAccepted eq 'true' || acceptedTerms == true}">checked</c:if>
        />
        Aceito os termos
    </div>

    <div class="p-row">
      <pre>* Campos obrigatórios</pre>
    </div>

    <div class="p-row">
      <button type="submit">Avançar</button>
    </div>

    <p class="p-footnote">
      Obs: os dados ficam guardados na <strong>sessão do portlet</strong>.
    </p>
  </form>
</div>
