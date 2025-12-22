# Portlet Sample (JSP + JSR-286 + Java 8)

Este projeto é um esqueleto **portável** para rodar em:
- Apache Pluto (Portal Driver) para desenvolvimento local
- WebSphere Portal Server 9 / HCL Digital Experience (DX) 9

## Requisitos
- Java 8
- Maven 3.x

## Build
```bash
mvn clean package
```

Vai gerar:
- `target/portlet-sample.war`

## Estrutura
- `src/main/java/.../SimpleMvcPortlet.java` -> GenericPortlet (doView, processAction, serveResource)
- `src/main/webapp/WEB-INF/portlet.xml` -> Portlet 2.0 (JSR-286)
- `src/main/webapp/WEB-INF/jsp/view.jsp` -> view (JSP)
- `src/main/webapp/static/portlet.css` -> CSS servido via `serveResource()` (resourceId=static)

## Observações de portabilidade
- Mantém apenas `javax.portlet.*` (JSR-286). Evite APIs/tags proprietárias do portal.
- Dependências `portlet-api` e `servlet-api` estão como `provided`.

## Endpoint AJAX
O JSP chama:
- Resource URL com `action=ping`
Retorna JSON: `{ ok: true, action: "ping", message: "pong" }`

## CSS
O CSS é servido via:
- `<portlet:resourceURL id="static">` com param `path=/static/portlet.css`
e tratado em `serveResource()` quando `request.getResourceID()` é `"static"`.
