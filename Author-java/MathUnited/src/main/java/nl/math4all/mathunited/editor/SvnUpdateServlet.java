package nl.math4all.mathunited.editor;

import nl.math4all.mathunited.configuration.*;
import nl.math4all.mathunited.utils.SvnException;
import nl.math4all.mathunited.utils.SvnUtils;
import nl.math4all.mathunited.utils.UserManager;
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
import java.util.Properties;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.logging.Level;
import java.util.logging.Logger;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class SvnUpdateServlet extends HttpServlet {

    private final static Logger LOGGER = Logger.getLogger(SvnUpdateServlet.class.getName());

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

        if (repo == null) {
            writer.println("!!! NOT LOGGED IN");
            return;
        }

        if (lock.tryLock()) {
            try {
                writer.println("=== PERFORMING GLOBAL SVN UPDATE on " + config.getContentRoot());

                /*
                String[] commands = {"svn", "status", config.getContentRoot()};
                Process process = Runtime.getRuntime().exec(commands);
                */

                ProcessBuilder pb = new ProcessBuilder("svn", "update", config.getContentRoot());
                pb.redirectErrorStream(true);
                Process process = pb.start();
                BufferedReader is = new BufferedReader(new InputStreamReader(process.getInputStream()));
                String line;
                while ((line = is.readLine()) != null) {
                    writer.println(line);
                }

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