package br.com.wagner.portlet;

import com.google.gson.Gson;

import javax.portlet.*;
import java.io.*;
import java.util.HashMap;
import java.util.Map;

/**
 * Portlet 2.0 (JSR-286) "MVC simples":
 * - doView() -> encaminha para JSP (VIEW)
 * - processAction() -> processa POST/Action e define render parameters
 * - serveResource() -> endpoint para AJAX/JSON (RESOURCE) e também serve recursos estáticos (CSS) via resourceId
 *
 * Compatível com Pluto e WebSphere Portal 9/DX quando você mantém apenas javax.portlet.*.
 */
public class SimpleMvcPortlet extends GenericPortlet {

    private static final String JSP_VIEW = "/WEB-INF/jsp/view.jsp";
    private final Gson gson = new Gson();

    @Override
    protected void doView(RenderRequest request, RenderResponse response)
            throws PortletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        String lastMessage = request.getParameter("lastMessage");
        if (lastMessage != null) {
            request.setAttribute("lastMessage", lastMessage);
        }

        PortletRequestDispatcher dispatcher = getPortletContext().getRequestDispatcher(JSP_VIEW);
        dispatcher.include(request, response);
    }

    @Override
    public void processAction(ActionRequest request, ActionResponse response)
            throws PortletException, IOException {

        String msg = request.getParameter("message");
        if (msg == null) msg = "";

        response.setRenderParameter("lastMessage", msg.trim());
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
        if (contentType != null) {
            response.setContentType(contentType);
        }

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
