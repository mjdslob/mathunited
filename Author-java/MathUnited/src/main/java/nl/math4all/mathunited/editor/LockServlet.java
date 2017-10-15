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
import nl.math4all.mathunited.utils.Lock;
import nl.math4all.mathunited.utils.LockManager;
import nl.math4all.mathunited.utils.UserManager;
import nl.math4all.mathunited.utils.Utils;
import org.apache.commons.lang3.StringUtils;

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

            LockManager lm = LockManager.getInstance(getServletContext());
            Lock lock = lm.getLock(usettings.username, config.getContentRoot() + refbase);
            String currentOwner = lock.getUsername();

            response.setContentType("application/xml");
            PrintWriter writer = response.getWriter();
            String resultStr;
            if (currentOwner != null && StringUtils.equals(usettings.username, currentOwner)) {
                resultStr = String.format("<refresh-lock success='true' session-start='%s' last-update='%s' last-commit='%s' />",
                        ShowLocksServlet.stringForTimestamp(lock.getSessionStart()),
                        ShowLocksServlet.stringForTimestamp(lock.getLastUpdate()),
                        ShowLocksServlet.stringForTimestamp(lock.getLastCommit()));
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

    @Override
    public void doPost (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {
        //get the pdf from the session and return it
    }

    /** Clean up lock manager */
    @Override
    public void destroy() {
        LockManager.getInstance(getServletContext()).shutdown();
        super.destroy();
    }


}