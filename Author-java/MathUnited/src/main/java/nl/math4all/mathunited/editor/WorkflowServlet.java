package nl.math4all.mathunited.editor;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;
import java.io.BufferedReader;
import java.io.FileReader;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.StringTokenizer;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import nl.math4all.mathunited.configuration.Component;
import nl.math4all.mathunited.configuration.SubComponent;
import nl.math4all.mathunited.configuration.Configuration;
import nl.math4all.mathunited.configuration.Repository;
import nl.math4all.mathunited.utils.Utils;

/**
 * @author Martijn Slob <m.slob@math4all.nl>
 */
public class WorkflowServlet extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(WorkflowServlet.class.getName());

    private static final String STATUS_MAP_NAME = "statusMap";

    static Map<String, Map<String, String>> statusMap = new HashMap<String, Map<String, String>>();

    /**
     * map of repo to a (map of subcomp-id to status)
     */

    public static Map<String, Map<String, String>> getStatusMap() {
        return statusMap;
    }

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        LOGGER.setLevel(Level.INFO);
    }

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request  servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            LOGGER.fine("Request: WorkflowServlet");
            response.setContentType("application/xml");
            Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            Map<String, String> parameterMap = Utils.readParameters(request);

            String repo = parameterMap.get("repo");
            String reread = parameterMap.get("reread");

            Map<String, Map<String,String>> statusMap = getStatusMap();
            Map<String, String> repoMap = statusMap.get(repo);

            if (repoMap == null || Objects.equals(reread, "true")) {
                LOGGER.info("(Re)reading '" + repo + "'.");
                readComponentStatus(repo);
                repoMap = statusMap.get(repo);
                if (repoMap == null) {
                    throw new Exception("<error>Could not get info on repository " + repo + "</error");
                }
            }

            pw.println("<repo id='" + repo + "'>");
            for (Map.Entry<String, String> entry : repoMap.entrySet()) {
                pw.println("<subcomp id='" + entry.getKey() + "' status='" + entry.getValue() + "'/>");
            }
            pw.println("</repo>");

        } catch (Exception e) {
            System.out.println(Utils.echoContext(request, "ERROR"));
            Utils.writeError(response, e);
        }

    }

    static void updateStatus(ServletContext context, String repo, String subcomp, String path) throws Exception {
        Map<String, Map<String,String>> statusMap = getStatusMap();
        Map<String, String> compStatusMap = statusMap.get(repo);
        if (compStatusMap != null) {
            String status = extractStatus(path);
            compStatusMap.put(subcomp, status);
        }
    }

    private void readComponentStatus(String repo) throws Exception {
        Configuration config = Configuration.getInstance();

        Map<String, Repository> repoMap = config.getRepos();
        Repository repository = repoMap.get(repo);
        if (repository == null) {
            throw new Exception("Onbekende repository: " + repo);
        }

        Map<String, Component> componentMap = repository.readComponentMap();

        Map<String, Map<String,String>> statusMap = getStatusMap();
        Map<String, String> compStatusMap = statusMap.get(repo);
        if (compStatusMap == null) {
            compStatusMap = new HashMap<String, String>();
            statusMap.put(repo, compStatusMap);
        }
        for (Component cc : componentMap.values()) {
            for (SubComponent ss : cc.subComponentList) {
                String status = readSubcomponentStatus(ss, repository, config);
                compStatusMap.put(ss.id, status);
            }
        }
    }

    private String readSubcomponentStatus(SubComponent sub, Repository repository, Configuration config) throws IOException {
        String result = "unknown";
        String path = config.contentRoot + repository.getPath() + "/" + sub.file;

        return extractStatus(path);
    }

    private static String extractStatus(String path) throws IOException {
        String result = null;

        //don't parse the whole document, just search the for the text: <subcomponent ... status=".." ..>
        //note that the status can be absent.

        BufferedReader br = null;
        try {
            br = new BufferedReader(new FileReader(path));
            StringBuilder sb = new StringBuilder();
            String line = br.readLine();

            while (line != null) {
                sb.append(line);
                sb.append(System.getProperty("line.separator"));
                line = br.readLine();
            }
            String text = sb.toString();

            int i0 = text.indexOf("<subcomponent");
            if (i0 < 0) {
                throw new Exception("Invalid subcomponent: " + path);
            }

            int i1 = text.indexOf(">", i0);
            if (i1 < 0) {
                throw new Exception("Invalid subcomponent: " + path);
            }
            int ii = text.indexOf("status", i0);
            if (ii > 0) {
                i0 = text.indexOf("\"", ii);
                i1 = text.indexOf("\"", i0 + 1);
                if (i0 > 0 && i1 > i0) {
                    result = text.substring(i0 + 1, i1);
                }
                LOGGER.log(Level.FINE, "Found status: subcomp={0}, status={1}", new Object[]{path, result, i0, i1});
            }

        } catch (Exception e) {
            LOGGER.severe("Error occurred: " + e.getMessage());
        } finally {
            if (br != null) br.close();
        }
        if (result == null) result = "unknown";
        return result;
    }
    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">

    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request  servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request  servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
