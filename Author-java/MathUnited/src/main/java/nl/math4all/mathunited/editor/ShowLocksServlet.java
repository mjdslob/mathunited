package nl.math4all.mathunited.editor;

import nl.math4all.mathunited.configuration.Configuration;
import nl.math4all.mathunited.utils.*;
import org.apache.commons.lang3.StringUtils;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class ShowLocksServlet extends HttpServlet {

    private final static Logger LOGGER = Logger.getLogger(ShowLocksServlet.class.getName());

    // Format for dates
    //private static SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
    private static SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"); // no millis

    static String stringForTimestamp(long t) {
        String msg;
        if (t == Lock.TIMESTAMP_NEVER) {
            msg = "never";
        } else if (t == Lock.TIMESTAMP_FAILED) {
            msg = "<span style='color:yellow;background-color:red'>FAILED</span>";
        } else {
            msg = sdf.format(new Date(t));
        }
        return msg;
    }

    @Override
    public void doGet(HttpServletRequest request,
                      HttpServletResponse response)
            throws ServletException, IOException
    {
        PrintWriter writer = response.getWriter();

        // Force login
        try {
            UserManager.isLoggedIn(request);
        } catch (Exception e) {
            writer.println("!!! NOT LOGGED IN");
            return;
        }

        // Get the lock map
        HashMap<String, Lock> locks = LockManager.getInstance(getServletContext()).getLockMap();
        Date now = new Date();

        // Select output type
        Map<String, String> params = Utils.readParameters(request);
        String type = params.get("type");

        if (StringUtils.equals(type, "text")) {
            // Plain text output
            response.setContentType("text/plain");

            // Write a plain text table
            writer.println("User,Base,SessionStart,Timestamp,Active");
            for (Lock lock : locks.values()) {
                writer.printf("%s,%s,%d,%d,%d", lock.getUsername(), lock.getRefbase(), lock.getSessionStart(), lock.getTimestamp(),lock.isActive() ? 1 : 0);
            }
        } else if (StringUtils.equals(type, "xml")) {
            // XML output
            response.setContentType("text/xml");
            writer.println("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
            writer.printf("<locks timestamp='%d'>", now.getTime());
                // Write a plain text table
            for (Lock lock : locks.values()) {
                writer.printf("\t<lock sessionStart='%d' timestamp='%d' active='%s'><user>%s</user><path>%s</path></lock>\n",
                        lock.getSessionStart(), lock.getTimestamp(), lock.isActive(), lock.getUsername(), lock.getRefbase());
            }
            writer.println("</locks>");
        } else {
            // HTML output
            response.setContentType("text/html");


            // Path prefix to subtract from paths
            Configuration config = Configuration.getInstance();
            String root = config.getContentRoot();

            writer.println("<html>\n<head>");
            writer.println("\t<title>Lock information</title>");

            // JQuery + data tables
            String scriptFmt = "\t<script type=\"text/javascript\" language=\"javascript\" src=\"%s\"></script>\n";
            String cssFmt = "\t<link rel=\"stylesheet\" type=\"text/css\" href=\"%s\">\n";

            writer.printf(cssFmt, "css/M4AStijl2.css");
            writer.printf(cssFmt, "css/editor.css");
            writer.printf(cssFmt, "https:////cdn.datatables.net/1.10.16/css/jquery.dataTables.min.css");

            writer.printf(scriptFmt, "https://cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js");
            writer.printf(scriptFmt, "https://cdn.datatables.net/1.10.16/js/jquery.dataTables.min.js");

            writer.println("</head>\n<body>");
            writer.print("<div class='editorDiv'>\n<br><h1>Lock information</h1>\n<p>Overview of locks at ");
            writer.print(sdf.format(now));
            writer.println("</p>\n<p>");

            // Table + header.
            writer.println("<table id='locks-table' class='display' style='font-size:small;'>\n" +
                    "\t<thead>\n\t<tr>\n" +
                    "\t\t<th>User</th>\n" +
                    "\t\t<th>Path</th>\n" +
                    "\t\t<th>Session start</th>\n" +
                    "\t\t<th>Active</th>\n" +
                    "\t\t<th>Timestamp</th>\n" +
                    "\t\t<th>Time since refresh</th>\n" +
                    "\t\t<th>Last update</th>\n" +
                    "\t\t<th>Last commit</th>\n" +
                    "\t</tr>\n\t</thead>\n\t<tbody>");

            // Row entries for each lock
            for (Lock lock : locks.values()) {
                // 1. Username
                writer.print("\t\t<tr><td>");
                writer.print(lock.getUsername());

                // 2. Refbase
                writer.print("</td><td>");
                writer.print(lock.getRefbase().replace(root, ""));

                // 3. Session start
                writer.print("</td><td>");
                writer.print(stringForTimestamp(lock.getSessionStart()));

                // 4. Active
                writer.print("</td><td>");
                writer.print(lock.isActive() ? "yes" : "no");

                // 5. Refresh timestamp
                writer.print("</td><td>");
                writer.print(stringForTimestamp(lock.getTimestamp()));

                // 6. Refresh timestamp as seconds ago from now
                writer.print("</td><td>");
                double sec = 1e-3 * (now.getTime() - lock.getTimestamp());
                writer.printf("%.3fs", sec);

                // 7. Last (e.g. SVN) update time
                writer.print("</td><td>");
                writer.print(stringForTimestamp(lock.getLastUpdate()));

                // 8. Last (e.g. SVN) commit time
                writer.print("</td><td>");
                writer.print(stringForTimestamp(lock.getLastCommit()));
                writer.println("</td></tr>");
            }
            writer.println("\t</tbody>\n</table>\n</p></div>");

            // Intialize datatables
            writer.println("<script>\n"+
                    "$(document).ready(function(){\n" +
                    "    $('#locks-table').DataTable(" +
                    // This makes the 2nd column wider (for path names)
                    "{'columnDefs': [{'targets':1, 'width':'20%'}]});\n" +
                    "});\n" +
                    "</script>"
            );

            writer.println("</body>");
        }
    }

    @Override
    public void doPost(HttpServletRequest request,
                       HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

}