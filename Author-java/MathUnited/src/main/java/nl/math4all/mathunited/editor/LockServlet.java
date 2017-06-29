package nl.math4all.mathunited.editor;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.Map;
import java.util.HashMap;
import java.util.Properties;
import nl.math4all.mathunited.configuration.*;
import nl.math4all.mathunited.configuration.Component;
import nl.math4all.mathunited.utils.LockManager;
import nl.math4all.mathunited.utils.UserManager;
import nl.math4all.mathunited.utils.Utils;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class LockServlet extends HttpServlet {

    private final static Logger LOGGER = Logger.getLogger(LockServlet.class.getName());
    Map<String, Component> componentMap;
    Properties prop = new Properties();

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        LOGGER.setLevel(Level.INFO);
    }

    @Override
    public void doGet (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {

        try{
            Configuration config = Configuration.getInstance();

            UserSettings usettings = UserManager.isLoggedIn(request);
            
            // Read request parameters
            Map<String, String> parameterMap = Utils.readParameters(request);

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
            System.out.println(Utils.echoContext(request, "ERROR"));
            Utils.writeError(response, e);
        }

    }

    /** Tries to7 get the lock on this subcomponent.
     * @param username
     * @param refbase
     * @return null if lock is obtained. If the lock is owned by some other user, the
     *         username of this current owner is returned.
     * @throws Exception 
     */
    public static String getLock(String username, String refbase) throws Exception {
        return LockManager.getInstance().getLock(username, refbase);
    }
    
    @Override
    public void doPost (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {
        //get the pdf from the session and return it
    }

    /** Clean up lock manager */
    @Override
    public void destroy() {
        LockManager.getInstance().shutdown();
        super.destroy();
    }


}