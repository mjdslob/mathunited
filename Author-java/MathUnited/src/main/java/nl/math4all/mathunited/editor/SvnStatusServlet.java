package nl.math4all.mathunited.editor;

import nl.math4all.mathunited.configuration.Configuration;
import nl.math4all.mathunited.utils.Utils;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.util.HashMap;
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

    ServletContext context;

    @Override
    public void init(ServletConfig config) throws ServletException {
        try {
            super.init(config);
            context = getServletContext();
            LOGGER.setLevel(Level.INFO);
        } catch (Exception e) {
            e.printStackTrace();
            LOGGER.log(Level.SEVERE, e.getMessage());
        }
    }

    private static Lock lock = new ReentrantLock();

    @Override
    public void doGet(HttpServletRequest request,
                      HttpServletResponse response)
            throws ServletException, IOException
    {
        Configuration config = Configuration.getInstance();
        response.setContentType("text/plain");
        PrintWriter writer = response.getWriter();

        //read request parameters
        Map<String, String[]> paramMap = request.getParameterMap();
        Map<String, String> parameterMap = new HashMap<>();
        for (Map.Entry<String, String[]> entry : paramMap.entrySet()) {
            String pname = entry.getKey();
            String[] pvalArr = entry.getValue();
            if (pvalArr != null && pvalArr.length > 0) {
                parameterMap.put(pname, pvalArr[0]);
            }
        }
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

        if (lock.tryLock()) {
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
                writer.println("=== SVN STATUS on " + svnPath);

                /*
                String[] commands = {"svn", "status", config.getContentRoot()};
                Process process = Runtime.getRuntime().exec(commands);
                */

                ProcessBuilder pb = new ProcessBuilder("svn", "status", svnPath);
                pb.redirectErrorStream(true);
                LOGGER.log(Level.INFO, "--- svn-status command = '" + pb.command() + "'.");
                Process process = pb.start();
                BufferedReader is = new BufferedReader(new InputStreamReader(process.getInputStream()));
                String line;
                while ((line = is.readLine()) != null) {
                    writer.println(line);
                }
            }
            catch (Exception e) {
                LOGGER.log(Level.WARNING, e.getMessage());
            }
            finally {
                lock.unlock();
            }
        } else {
            writer.println("!!! SVN UPDATE on " + config.getContentRoot() + " is already in progress");
            writer.println("!!! Not doing anything");
        }
    }

    @Override
    public void doPost(HttpServletRequest request,
                       HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

}