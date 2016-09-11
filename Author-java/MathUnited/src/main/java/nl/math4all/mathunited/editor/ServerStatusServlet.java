package nl.math4all.mathunited.editor;

import nl.math4all.mathunited.configuration.Configuration;
import nl.math4all.mathunited.utils.ScriptRunner;
import nl.math4all.mathunited.utils.Utils;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.logging.Level;
import java.util.logging.Logger;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class ServerStatusServlet extends BaseHttpServlet {

    private final static Logger LOGGER = Logger.getLogger(ServerStatusServlet.class.getName());

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

        // Find out which repository to use, so we force a logged in user
        // try to get repo from cookie
        String repo = null; // parameterMap.get("repo");
        Cookie[] cookieArr = request.getCookies();

        if(cookieArr != null) {
            for(Cookie c:cookieArr) {
                if(c.getName().equals("REPO")) {
                    repo = c.getValue();
                    parameterMap.put("repo",repo);
                }
            }
        }

        if (repo == null) {
            writer.println("!!! NOT LOGGED IN");
            return;
        }

        try {
            ScriptRunner runner = new ScriptRunner(writer);
            runner.runScript("server-stat");
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