package nl.math4all.mathunited.editor;

import nl.math4all.mathunited.configuration.Configuration;
import nl.math4all.mathunited.configuration.UserSettings;
import nl.math4all.mathunited.utils.ScriptRunner;
import nl.math4all.mathunited.utils.UserManager;
import nl.math4all.mathunited.utils.Utils;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.util.Map;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.logging.Level;
import java.util.logging.Logger;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class SvnStatusServlet extends HttpServlet {

    private final static Logger LOGGER = Logger.getLogger(SvnStatusServlet.class.getName());

    @Override
    public void doGet(HttpServletRequest request,
                      HttpServletResponse response)
            throws ServletException, IOException
    {
        Configuration config = Configuration.getInstance();
        response.setContentType("text/plain");
        PrintWriter writer = response.getWriter();

        //read request parameters
        Map<String, String> parameterMap = Utils.readParameters(request);

        // Force login
        try {
            UserSettings usettings = UserManager.isLoggedIn(request,response);
        } catch (Exception e) {
            writer.println("!!! NOT LOGGED IN");
            return;

        }

        try {
            String svnPath = config.getContentRoot();
            String path = parameterMap.get("path");
            if (path != null && !path.isEmpty()) {
                File newPath = new File(svnPath, path);
                if (Utils.isSubDirectory(new File(svnPath), newPath)) {
                    svnPath = newPath.getCanonicalPath();
                } else {
                    writer.println("=== ILLEGAL REPO PATH " + newPath);
                    throw new Exception("Illegal svn path " + newPath);
                }
            }

            ScriptRunner runner = new ScriptRunner(writer);
            runner.runScript("svn-status", svnPath);

        }
        catch (Exception e) {
            LOGGER.log(Level.WARNING, e.getMessage());
        }
    }

    @Override
    public void doPost(HttpServletRequest request,
                       HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

}