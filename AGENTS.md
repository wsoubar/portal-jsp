# Orientações para agentes

## Comunicação e escopo

- Responda e escreva documentação em português brasileiro.
- Inspecione o código antes de editar e prefira mudanças pequenas, coesas e compatíveis com a arquitetura existente.
- Preserve alterações preexistentes. Não faça commits, pushes ou operações destrutivas sem autorização explícita.
- Não introduza dependências, migrações de plataforma ou refatorações fora do escopo solicitado.

## Contexto do projeto

Este repositório contém um portlet JSR-286 (Portlet 2.0), com Java 8, Maven, JSP/JSTL, Spring Framework 5.3.30 e Gson. O empacotamento é WAR. O README indica Apache Pluto e WebSphere Portal 9/HCL DX 9 como ambientes de destino; a compatibilidade precisa ser validada no contêiner utilizado.

Não é uma aplicação Spring Boot nem um servidor autônomo. O contexto Spring é criado pelo próprio portlet.

## Estrutura

- `pom.xml`: dependências, compilação Java 8 e geração do WAR.
- `src/main/java/br/com/wagner/portlet/SimpleMvcPortlet.java`: ciclo de vida, renderização, processamento do formulário, sessão e recursos JSON/estáticos.
- `src/main/java/br/com/wagner/portlet/config/AppConfig.java`: configuração Spring e descoberta de componentes.
- `src/main/java/br/com/wagner/service/ChatService.java`: serviço Spring de exemplo.
- `src/main/webapp/WEB-INF/portlet.xml`: registro e metadados do portlet.
- `src/main/webapp/WEB-INF/web.xml`: descritor Servlet 3.1.
- `src/main/webapp/WEB-INF/jsp/`: identificação (`view.jsp`) e cliente de chat (`chat.jsp`).
- `src/main/webapp/static/css/` e `src/main/webapp/static/js/`: estilos e JavaScript sem etapa de build frontend.

## Convenções e contratos

- Mantenha compatibilidade com Java 8 e com os pacotes `javax.portlet` e `javax.servlet`; não migre para `jakarta.*` sem solicitação.
- Preserve o escopo Maven `provided` das APIs Portlet e Servlet, fornecidas pelo contêiner.
- Use as URLs geradas pelas tags Portlet para ações, renderização e recursos; evite URLs fixas que dependam do contexto do portal.
- Use `<portlet:namespace/>` nos identificadores DOM e mantenha o vínculo com os seletores em `chat.js`.
- Preserve o uso de `PortletSession.PORTLET_SCOPE` para dados próprios da instância.
- Recursos estáticos passam por `serveResource()`, com resource ID `static` e parâmetro `path` sob `/static/`.
- As ações JSON existentes são `ping`, `getwsurl` e `sessioninfo`. Confira os consumidores antes de alterar parâmetros ou formatos de resposta.
- Mantenha UTF-8 em Java, JSP e respostas. Escape dados do usuário ao renderizar HTML e valide entradas no servidor.
- Não registre dados pessoais, mensagens ou credenciais em novos logs. Trate os endereços WebSocket existentes como exemplos, sem presumir disponibilidade externa.

## Build e validação

- Build documentado com JDK 25 e Maven 3.x, gerando classes compatíveis com Java 8. Não há Maven Wrapper versionado.
- Mantenha `maven.compiler.release=8` e o Maven Compiler Plugin 3.13.0. Com JDK 25, `--release 8` limita sintaxe, APIs da plataforma e bytecode ao Java 8, sem alterar `JAVA_HOME` ou exigir JDK 8 instalado.
- Execute `mvn clean package` para compilar e gerar `target/portlet-sample.war`.
- Execute `mvn test` quando houver testes relevantes. Atualmente não há suíte de testes em `src/test/`.
- Execute `git diff --check` e revise o diff ao concluir alterações.
- Não versione `target/` nem artefatos gerados.
- O build Maven não comprova renderização das JSPs, integração com o portal ou conexão WebSocket. Para mudanças nesses fluxos, valide no contêiner: identificação, campos obrigatórios, aceite dos termos, navegação ao chat, chamada AJAX `ping` e conexão/envio/desconexão WebSocket, conforme o escopo.
- Informe quais verificações foram executadas e quais ficaram pendentes por falta de ambiente ou serviço externo.

## Documentação

Atualize o README quando mudar requisitos, build, implantação ou contratos documentados. Confira os caminhos no código: o CSS atual fica em `/static/css/portlet.css`, embora o README ainda mencione `/static/portlet.css`.
