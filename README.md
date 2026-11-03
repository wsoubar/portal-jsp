# Portlet Sample (JSP + JSR-286 + Java 8)

Este projeto é um esqueleto **portável** para rodar em:
- Apache Pluto (Portal Driver) para desenvolvimento local
- WebSphere Portal Server 9 / HCL Digital Experience (DX) 9

## Requisitos
- JDK 25 para o build descrito abaixo; ambiente de execução compatível com Java 8
- Maven 3.x

## Build
O Maven usa o JDK indicado por `JAVA_HOME`, que pode continuar apontando para o
JDK 25. O Maven Compiler Plugin 3.13.0 está configurado com `release=8`:
o compilador limita a sintaxe, as APIs da plataforma Java e o bytecode ao Java 8
(major version 52). Não é necessário instalar ou selecionar um JDK 8.

```bash
mvn clean package
```

Vai gerar:
- `target/portlet-sample.war`

Essa compilação não substitui a validação do WAR no portal de destino com Java 8.

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
