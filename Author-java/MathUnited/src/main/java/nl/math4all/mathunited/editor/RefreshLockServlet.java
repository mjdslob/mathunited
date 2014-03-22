package nl.math4all.mathunited.editor;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.Map;
import java.util.HashMap;
import javax.xml.transform.Source;
import org.xml.sax.InputSource;
import java.util.Properties;
import nl.math4all.mathunited.resolvers.ContentResolver;
import nl.math4all.mathunited.configuration.*;
import nl.math4all.mathunited.configuration.SubComponent;
import nl.math4all.mathunited.configuration.Component;
import nl.math4all.mathunited.exceptions.LoginException;
import nl.math4all.mathunited.utils.UserManager;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class RefreshLockServlet extends HttpServlet {
    private static final int MAX_LOCK_DURATION_SECONDS = 60;
    
    private final static Logger LOGGER = Logger.getLogger(RefreshLockServlet.class.getName());
    Map<String, Component> componentMap;
    ServletContext context;
    Properties prop = new Properties();
    
    @Override
    public void init(ServletConfig config) throws ServletException {
        try{
            super.init(config);
            context = getServletContext();
            LOGGER.setLevel(Level.INFO);
        } catch(Exception e) {
            e.printStackTrace();
            LOGGER.log(Level.SEVERE, e.getMessage());
        }
    }

    @Override
    public void doGet (  HttpServletRequest request,
                         HttpServletResponse response)
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

            String refbase = parameterMap.get("refbase");

            String currentOwner = getLock(usettings.username, config.getContentRoot()+refbase);

            response.setContentType("application/xml");
            PrintWriter writer = response.getWriter();
            String resultStr;
            if( currentOwner!=null ) {
                resultStr = "<refresh-lock success='true'/>";
            } else {
                resultStr = "<refresh-lock success='false'/>";
            }
            writer.println(resultStr);
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

    /** Tries to get the lock on this subcomponent. 
     * @param username
     * @param refbase
     * @return null if lock is obtained. If the lock is owned by some other user, the
     *         username of this current owner is returned.
     * @throws Exception 
     */
    public String getLock(String username, String refbase) throws Exception {
        //lock file: refbase/lock
        boolean allowed = true;
        boolean create = false;
        String userStr = null;
        File lockFile = new File(refbase+"lock");
        
        if(!lockFile.exists()) {
            LOGGER.fine("Creating lock file for "+refbase);
            create = true;
        } else {
            java.util.Date date = new java.util.Date();
            long modified = lockFile.lastModified();
            long current = date.getTime();
            if(current-modified > MAX_LOCK_DURATION_SECONDS*1000) {
                //steal lock
                LOGGER.fine("Stealing lockfile for "+refbase+" (last modified "+((current-modified)/1000)+" seconds ago");
                create = true;
            } else {
                //check if this is the same user
                BufferedReader br = new BufferedReader(new FileReader(lockFile));
                userStr = br.readLine();
                if(userStr==null || userStr.isEmpty()) {
                    //invalid lockfile. Probably changed manually.
                    userStr = null;
                    create = true;
                } else {
                    if(!username.equals(userStr)) {
                        LOGGER.info("Editing not allowed: lock for "+refbase+" is currenlth owned by "+userStr);
                        allowed = false;
                    } else {
//                        LOGGER.info("Refreshing timestamp on lock for "+refbase);
                        lockFile.setLastModified(current);
                    }
                }
            }
        } 
        
        if(allowed && create) {
            BufferedWriter out = new BufferedWriter(new FileWriter(lockFile));
            out.write(username);
            out.close();
        }
        
        return userStr;
    }
    
    @Override
    public void doPost (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {
        //get the pdf from the session and return it
    }

}