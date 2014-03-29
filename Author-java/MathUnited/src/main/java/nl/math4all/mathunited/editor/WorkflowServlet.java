package nl.math4all.mathunited.editor;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;
import java.io.BufferedReader;
import java.io.FileReader;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import nl.math4all.mathunited.XSLTbean;
import nl.math4all.mathunited.configuration.Component;
import nl.math4all.mathunited.configuration.SubComponent;
import nl.math4all.mathunited.configuration.Configuration;
import nl.math4all.mathunited.configuration.Repository;
import org.xml.sax.InputSource;

/**
 *
 * @author Martijn Slob <m.slob@math4all.nl>
 */
public class WorkflowServlet extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(WorkflowServlet.class.getName());

    /** map of repo to a (map of subcomp-id to status) */
    private static Map<String, Map<String, String>> statusMap=new HashMap<String, Map<String, String>>();
    
    @Override
    public void init(ServletConfig config) throws ServletException {
        try{
            super.init(config);
            LOGGER.setLevel(Level.INFO);
        } catch(Exception e) {
            System.out.println(e.getMessage());
        }
    }

    public static void clear() { statusMap.clear(); }
    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try{
            LOGGER.fine("Request: WorkflowServlet");
            response.setContentType("application/xml");
            Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            Map<String, String[]> paramMap = request.getParameterMap();
            Map<String, String> parameterMap = new HashMap<String, String>();
            for(Map.Entry<String, String[]> entry : paramMap.entrySet()) {
                String pname = entry.getKey();
                String[] pvalArr = entry.getValue();
                if(pvalArr!=null && pvalArr.length>0) {
                   parameterMap.put(pname, pvalArr[0]);
                }
            }
            String repo = parameterMap.get("repo");
            
            Map<String, String> repoMap = statusMap.get(repo);
            if(repoMap==null) {
                readComponentStatus(repo);
                repoMap = statusMap.get(repo);
                if(repoMap==null) {
                    throw new Exception("<error>Could not get info on repository "+repo+"</error");
                }
            }
            
            pw.println("<repo id='"+repo+"'>");
            for(Map.Entry<String, String> entry : repoMap.entrySet()) {
                pw.println("<subcomp id='"+entry.getKey()+"' status='"+entry.getValue()+"'/>");
            }
            pw.println("</repo>");
            
        }
        catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html");
            Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            pw.println("<html><head></head><body><h1>Fout opgetreden</h1><p>");
            pw.println(e.getMessage());
            pw.println("</p></body></html>");
//            throw new ServletException(e);
        }
        
    }

    public static void updateStatus(String repo, String subcomp, String path) throws Exception {
        Map<String, String> compStatusMap = statusMap.get(repo);
        if(compStatusMap!=null) {
            String status = extractStatus(path);
            compStatusMap.put(subcomp, status);
        }
    }
    
    private void readComponentStatus(String repo) throws Exception {
        Configuration config = Configuration.getInstance();

        Map<String, Repository> repoMap = config.getRepos();
        Repository repository = repoMap.get(repo);
        if(repository==null) {
            throw new Exception("Onbekende repository: "+repo);
        }

        Map<String, Component> componentMap = repository.readComponentMap();

        Map<String, String> compStatusMap = statusMap.get(repo);
        if(compStatusMap==null) {
            compStatusMap = new HashMap<String, String>();
            statusMap.put(repo, compStatusMap);
        }
        for(Component cc : componentMap.values()) {
            for(SubComponent ss : cc.subComponentList) {
                String status = readSubcomponentStatus(ss, repository, config);
                compStatusMap.put(ss.id, status);
            }
        }
    }

    private String readSubcomponentStatus(SubComponent sub,  Repository repository, Configuration config) throws IOException{
        String result = "unknown";
        String path = config.contentRoot+repository.getPath()+"/"+sub.file;

        return extractStatus(path);
    }
    
    private static String extractStatus(String path)  throws IOException{
        String result = null;
        //don't parse the whole document, just search the for the text: <subcomponent ... status=".." ..>
        //note that the status can be absent.

        BufferedReader br=null;
        try {
            br = new BufferedReader(new FileReader(path));
            StringBuilder sb = new StringBuilder();
            String line = br.readLine();

            while (line != null) {
                sb.append(line);
                sb.append(System.lineSeparator());
                line = br.readLine();
            }
            String text = sb.toString();
            
            int i0 = text.indexOf("<subcomponent");
            if(i0<0) throw new Exception("Invalid subcomponent: "+path);
            int i1 = text.indexOf(">",i0);
            if(i1<0) throw new Exception("Invalid subcomponent: "+path);
            int ii = text.indexOf("status",i0);
            if(ii>0) {
                i0 = text.indexOf("\"",ii);
                i1 = text.indexOf("\"",i0+1);
                if(i0>0 && i1>i0) {
                    result = text.substring(i0+1, i1);
                }
                LOGGER.log(Level.FINE, "Found status: subcomp={0}, status={1}", new Object[]{path, result,i0,i1});
            }
            
        } catch(Exception e) {
            LOGGER.severe("Error occurred: "+e.getMessage());
        } finally {
            if(br!=null) br.close();
        }
        if(result==null) result="unknown";
        return result;
    }
    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
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
