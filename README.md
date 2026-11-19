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

## Configuração local com Apache Pluto

O Pluto fornece o contêiner de portlets necessário para executar a aplicação.
O bundle do Pluto 3.1.2 já inclui o Tomcat. Faça o download do
[bundle no arquivo oficial da Apache](https://archive.apache.org/dist/portals/pluto/pluto-bundle-3.1.2.zip)
e extraia-o fora do repositório. O projeto Apache Pluto foi descontinuado; use
esse ambiente para desenvolvimento e testes locais.

Os exemplos abaixo consideram o Pluto extraído em `/home/wagner/opt/pluto-3.1.2`
e o Temurin 8 instalado pelo SDKMAN. Ajuste os caminhos para a sua máquina.
O JDK usado para iniciar o Pluto pode ser diferente do JDK 25 usado no build.

### Usuário administrativo

No arquivo `conf/tomcat-users.xml` do Pluto, dentro do elemento `<tomcat-users>`,
configure um usuário com os papéis `pluto` e `manager-gui`:

```xml
<user name="admin" password="SUBSTITUA_POR_UMA_SENHA" roles="pluto,manager-gui" />
```

Escolha uma senha para o ambiente local e mantenha esse arquivo de configuração
fora do repositório. Se o usuário já existir, ajuste a entrada existente. Reinicie
o Pluto após alterar o arquivo.

### Inicialização e deploy

1. Gere o WAR com `mvn clean package` na raiz do projeto.
2. Copie `target/portlet-sample.war` para o diretório `webapps` do Pluto. Para
   atualizar uma implantação existente, substitua o WAR nesse diretório.
3. Inicie o Pluto com Java 8:

   ```bash
   JAVA_HOME="$HOME/.sdkman/candidates/java/8.0.482-tem" \
     /home/wagner/opt/pluto-3.1.2/bin/catalina.sh run
   ```

4. Acesse `http://localhost:8080/pluto/portal` e entre com o usuário configurado.
5. Na página **Pluto Admin**, crie uma página, por exemplo `Portlet Sample`.
   Selecione essa página, a aplicação `/portlet-sample` e o portlet
   `SimpleMvcPortlet`. Clique em **Add Portlet**.
6. Abra a página criada no menu do portal. Para encerrá-lo quando iniciado com
   `catalina.sh run`, pressione `Ctrl+C` no terminal.

Após o deploy, confira a identificação, a validação dos campos e do aceite, a
navegação para o chat e o retorno `pong` do AJAX. A conexão e a troca de mensagens
WebSocket dependem de um servidor acessível na URL informada na tela.

## Estrutura
- `src/main/java/.../SimpleMvcPortlet.java` -> GenericPortlet (doView, processAction, serveResource)
- `src/main/webapp/WEB-INF/portlet.xml` -> Portlet 2.0 (JSR-286)
- `src/main/webapp/WEB-INF/jsp/view.jsp` -> view (JSP)
- `src/main/webapp/static/css/portlet.css` -> CSS servido via `serveResource()` (resourceId=static)

## Observações de portabilidade
- Mantém apenas `javax.portlet.*` (JSR-286). Evite APIs/tags proprietárias do portal.
- Dependências `portlet-api` e `servlet-api` estão como `provided`.

## Endpoint AJAX
O JSP chama:
- Resource URL com `action=ping`
Retorna JSON: `{ ok: true, action: "ping", message: "pong" }`

## CSS
O CSS é servido via:
- `<portlet:resourceURL id="static">` com param `path=/static/css/portlet.css`
e tratado em `serveResource()` quando `request.getResourceID()` é `"static"`.
