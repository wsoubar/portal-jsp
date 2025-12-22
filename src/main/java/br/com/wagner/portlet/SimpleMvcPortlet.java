package br.com.wagner.portlet;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.GenericPortlet;
import javax.portlet.PortletException;
import javax.portlet.PortletSession;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import com.google.gson.Gson;

/**
 * Portlet 2.0 (JSR-286) "MVC simples":
 * - doView() -> escolhe qual JSP renderizar (view.jsp ou chat.jsp)
 * - processAction() -> recebe o POST do formulário (Avançar), valida e guarda em sessão
 * - serveResource() -> mantém seu endpoint JSON e recursos estáticos (se você usar)
 *
 * Compatível com Pluto e WebSphere Portal 9/DX quando você mantém apenas javax.portlet.*.
 */
public class SimpleMvcPortlet extends GenericPortlet {

    private final Gson gson = new Gson();

    @Override
    protected void doView(RenderRequest request, RenderResponse response)
            throws PortletException, IOException {

        response.setContentType("text/html; charset=UTF-8");

        // Copia o que está na sessão do portlet para o request (para EL nas JSPs).
        PortletSession session = request.getPortletSession(false);
        if (session != null) {
            request.setAttribute("userName", session.getAttribute("userName", PortletSession.PORTLET_SCOPE));
            request.setAttribute("userPhone", session.getAttribute("userPhone", PortletSession.PORTLET_SCOPE));
            request.setAttribute("acceptedTerms", session.getAttribute("acceptedTerms", PortletSession.PORTLET_SCOPE));
        }

        // Navegação por render parameter: view=chat -> chat.jsp, senão -> view.jsp
        String view = request.getParameter("view");
        String jsp = "chat".equals(view) ? "/WEB-INF/jsp/chat.jsp" : "/WEB-INF/jsp/view.jsp";

        getPortletContext().getRequestDispatcher(jsp).include(request, response);
    }

    @Override
    public void processAction(ActionRequest request, ActionResponse response)
            throws PortletException, IOException {

        // Form (view.jsp) -> botão "Avançar"
        String name = trimToEmpty(request.getParameter("name"));
        String phone = trimToEmpty(request.getParameter("phone"));
        boolean accepted = request.getParameter("acceptTerms") != null;

        // Validação mínima (ajuste conforme sua regra)
        if (name.isEmpty() || phone.isEmpty() || !accepted) {
            response.setRenderParameter("error", "Preencha Nome e Telefone e aceite os termos para continuar.");
            response.setRenderParameter("view", "home");

            // Prefill para não “perder” o que foi digitado
            response.setRenderParameter("prefillName", name);
            response.setRenderParameter("prefillPhone", phone);
            if (accepted) response.setRenderParameter("prefillAccepted", "true");
            return;
        }

        // Guarda em sessão do portlet (escopo PORTLET_SCOPE)
        PortletSession session = request.getPortletSession(true);
        session.setAttribute("userName", name, PortletSession.PORTLET_SCOPE);
        session.setAttribute("userPhone", phone, PortletSession.PORTLET_SCOPE);
        session.setAttribute("acceptedTerms", Boolean.TRUE, PortletSession.PORTLET_SCOPE);

        // Vai para o chat.jsp
        response.setRenderParameter("view", "chat");
    }

    private String trimToEmpty(String s) {
        return s == null ? "" : s.trim();
    }

    @Override
    public void serveResource(ResourceRequest request, ResourceResponse response)
            throws PortletException, IOException {

        // 1) Servir recursos estáticos via <portlet:resourceURL id="static">
        String resourceId = request.getResourceID();
        if ("static".equals(resourceId)) {
            serveStatic(request, response);
            return;
        }

        // 2) JSON para AJAX (ex.: action=ping)
        String action = request.getParameter("action");
        if (action == null) action = "";

        response.setContentType("application/json;charset=UTF-8");
        response.getCacheControl().setExpirationTime(0);

        Map<String, Object> payload = new HashMap<>();
        payload.put("ok", true);
        payload.put("action", action);

        if ("ping".equalsIgnoreCase(action)) {
            payload.put("message", "pong");
        } else {
            payload.put("message", "unknown action");
        }

        try (PrintWriter out = response.getWriter()) {
            out.print(gson.toJson(payload));
        }
    }

    private void serveStatic(ResourceRequest request, ResourceResponse response) throws IOException {
        String path = request.getParameter("path");
        if (path == null || !path.startsWith("/")) {
            response.setProperty(ResourceResponse.HTTP_STATUS_CODE, "400");
            response.getWriter().write("Invalid path");
            return;
        }

        // Proteção simples: só permite servir dentro de /static/
        if (!path.startsWith("/static/")) {
            response.setProperty(ResourceResponse.HTTP_STATUS_CODE, "403");
            response.getWriter().write("Forbidden");
            return;
        }

        String contentType = guessContentType(path);
        if (contentType != null) response.setContentType(contentType);

        response.getCacheControl().setExpirationTime(0);

        try (InputStream in = getPortletContext().getResourceAsStream(path)) {
            if (in == null) {
                response.setProperty(ResourceResponse.HTTP_STATUS_CODE, "404");
                response.getWriter().write("Not found");
                return;
            }
            try (OutputStream out = response.getPortletOutputStream()) {
                byte[] buf = new byte[8192];
                int r;
                while ((r = in.read(buf)) != -1) {
                    out.write(buf, 0, r);
                }
            }
        }
    }

    private String guessContentType(String path) {
        String p = path.toLowerCase();
        if (p.endsWith(".css")) return "text/css;charset=UTF-8";
        if (p.endsWith(".js")) return "application/javascript;charset=UTF-8";
        if (p.endsWith(".png")) return "image/png";
        if (p.endsWith(".jpg") || p.endsWith(".jpeg")) return "image/jpeg";
        if (p.endsWith(".gif")) return "image/gif";
        if (p.endsWith(".svg")) return "image/svg+xml";
        return null;
    }
}