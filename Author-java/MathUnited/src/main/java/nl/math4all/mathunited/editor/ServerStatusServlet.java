package nl.math4all.mathunited.editor;

import nl.math4all.mathunited.configuration.Configuration;
import nl.math4all.mathunited.configuration.UserSettings;
import nl.math4all.mathunited.utils.UnfencedScriptRunner;
import nl.math4all.mathunited.utils.UserManager;
import nl.math4all.mathunited.utils.Utils;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class ServerStatusServlet extends HttpServlet {

    private final static Logger LOGGER = Logger.getLogger(ServerStatusServlet.class.getName());

    @Override
    public void doGet(HttpServletRequest request,
                      HttpServletResponse response)
            throws ServletException, IOException
    {
        response.setContentType("text/plain");
        PrintWriter writer = response.getWriter();

        // Force login
        try {
            UserManager.isLoggedIn(request);
        } catch (Exception e) {
            writer.println("!!! NOT LOGGED IN");
            return;
        }

        try {
            UnfencedScriptRunner runner = new UnfencedScriptRunner(writer);
            runner.runScript("server-stat");
        }
        catch (Exception e) {
            System.out.println(Utils.echoContext(request, "ERROR"));
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