package nl.math4all.mathunited.editor;

import java.io.*;
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
import nl.math4all.mathunited.configuration.Component;
import nl.math4all.mathunited.configuration.Configuration;
import nl.math4all.mathunited.configuration.Repository;
import nl.math4all.mathunited.configuration.SubComponent;
import nl.math4all.mathunited.configuration.UserSettings;
import nl.math4all.mathunited.utils.UserManager;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 *
 * @author Martijn Slob <m.slob@math4all.nl>
 */
public class RestoreBackupServlet extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(RestoreBackupServlet.class.getName());
    Map<String, Component> componentMap;

    @Override
    public void init(ServletConfig config) throws ServletException {
        try{
            super.init(config);
            LOGGER.setLevel(Level.FINE);
        } catch(Exception e) {
            e.printStackTrace();
            LOGGER.log(Level.SEVERE, e.getMessage());
        }
    }

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
            Configuration config = Configuration.getInstance();

            UserSettings usettings = UserManager.isLoggedIn(request,response);
            
            //read request parameters
            Map<String, String[]> paramMap = request.getParameterMap();
            Map<String, String> parameterMap = new HashMap<String, String>();
            for(Map.Entry<String, String[]> entry : paramMap.entrySet()) {
                String pname = entry.getKey();
                String[] pvalArr = entry.getValue();
                if(pvalArr!=null && pvalArr.length>0) {
                   parameterMap.put(pname, pvalArr[0]);
                }
            }

            //find out which repository to use
            //try to get repo from cookie
            String repo = parameterMap.get("repo");
            Cookie[] cookieArr = request.getCookies();
            if(cookieArr != null) {
                for(Cookie c:cookieArr) {
                    if(c.getName().equals("REPO")) {
                        repo = c.getValue();
                        parameterMap.put("repo",repo);
                    }
                }
            }
            if(repo==null) {
                throw new Exception("Er is geen archief geselecteerd.");
            }

            String comp = parameterMap.get("comp");
            String subcomp = parameterMap.get("subcomp");            
            String entry = parameterMap.get("entry");            
            if(comp==null) {
                throw new Exception("Het verplichte argument 'comp' ontbreekt.");
            }
            if(subcomp==null) {
                throw new Exception("Het verplichte argument 'subcomp' ontbreekt.");
            }
            if(entry==null) {
                throw new Exception("Het verplichte argument 'entry' ontbreekt.");
            } else {
                entry = java.net.URLDecoder.decode(entry, "UTF-8");
            }
            
            Map<String, Repository> repoMap = config.getRepos();
            Repository repository = repoMap.get(repo);
            if(repository==null) {
                throw new Exception("Onbekende repository: "+repo);
            }
            LOGGER.log(Level.INFO, "Restoring backup: comp={0}, subcomp={1}, entry={2}", new Object[]{comp, subcomp, entry});
            
            //read components. 
            componentMap = repository.readComponentMap();
            Component component = componentMap.get(comp);
            if(component==null) {
                throw new Exception("Er bestaat geen component met id '"+comp+"'");
            }

            // find subcomponent
            SubComponent sub=null;
            int subcomp_index = 0;
            for(subcomp_index=0; subcomp_index<component.subComponentList.size(); subcomp_index++ ){
                sub = component.subComponentList.get(subcomp_index);
                if(sub.id.equals(subcomp))  break;
            }
            if(sub==null) {
                throw new Exception("Er bestaat geen subcomponent met id '"+subcomp+"'");
            }
            
            int ind = sub.file.lastIndexOf('/');
            String backupbase = config.getContentRoot()+repository.getPath()+"/_history/";
            String refbase = config.getContentRoot()+repository.getPath()+"/"+sub.file.substring(0, ind+1);
            File backupFile = new File(backupbase+entry);
          
            if(backupFile.exists()) {
                restoreBackup(backupFile, refbase);
            } else {
                LOGGER.severe("Log entry does not exist : "+backupFile.getAbsolutePath());
            }
            
        }
        catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html");
            Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            pw.println("<html><head></head><body><h1>Fout opgetreden</h1><p>");
            pw.println(e.getMessage());
            pw.println("</p></body></html>");
        }
    }
    
    private byte[] buffer = new byte[1024];

    private void restoreBackup(File zipFile, String refbase) throws Exception {
        File dir = new File(refbase);
        LOGGER.log(Level.INFO, "Cleaning directory {0}", dir.getAbsolutePath());
        for(File file: dir.listFiles()) file.delete();
        ZipInputStream zis = new ZipInputStream(new FileInputStream(zipFile));
    	//get the zipped file list entry
    	ZipEntry ze = zis.getNextEntry();
    	while(ze!=null){
    	   String fileName = ze.getName();
           File newFile = new File(refbase + File.separator + fileName);
           LOGGER.log(Level.FINE, "file unzip : {0}", newFile.getAbsoluteFile());
           FileOutputStream fos = new FileOutputStream(newFile);             
           int len;
           while ((len = zis.read(buffer)) > 0) {
       		fos.write(buffer, 0, len);
           }
           fos.close();   
           ze = zis.getNextEntry();
    	}
        zis.closeEntry();
    	zis.close();
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
