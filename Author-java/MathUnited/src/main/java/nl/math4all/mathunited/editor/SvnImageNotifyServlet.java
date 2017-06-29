package nl.math4all.mathunited.editor;

import nl.math4all.mathunited.configuration.Configuration;
import nl.math4all.mathunited.utils.ScriptRunner;
import nl.math4all.mathunited.utils.UnfencedScriptRunner;
import nl.math4all.mathunited.utils.Utils;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class SvnImageNotifyServlet extends HttpServlet {

    private final static Logger LOGGER = Logger.getLogger(SvnImageNotifyServlet.class.getName());

    private Set<String> localAddresses = new HashSet<String>();
    {
        try {
            localAddresses.add(InetAddress.getLocalHost().getHostAddress());
            for (InetAddress inetAddress : InetAddress.getAllByName("localhost")) {
                localAddresses.add(inetAddress.getHostAddress());
            }
        } catch (IOException e) {
            // Ignore.
        }
    }

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

        // Force localhost
        if (!localAddresses.contains(request.getRemoteAddr())) {
            writer.println("To be or not to be.");
            return;
        }

        // Locally accessed

        // Get image path (relative on server)
        String imagePathString = parameterMap.get("path").trim();

        // Get relative to content root
        imagePathString = imagePathString.replaceFirst("/data", "");

        // Get path of repo
        String svnPathString = config.getContentRoot();
        Path svnPath = Paths.get(svnPathString).toAbsolutePath();

        // Create image path
        Path imagePath = Paths.get(svnPathString, imagePathString).toAbsolutePath();

        // Check if image path is under svnPath
        if (!imagePath.startsWith(svnPath)) {
            String msg = imagePath + " is not under SVN control.";
            LOGGER.warning(msg);
            writer.println(msg);
            return;
        }

        // Check that the file exists
        if (!Files.isRegularFile(imagePath)) {
            String msg = imagePath + " does not exist.";
            LOGGER.warning(msg);
            writer.println(msg);
            return;
        }

        LOGGER.info("New image notified on " + imagePath);
        writer.println("Registered image " + imagePath);

        // Commit image
        ScriptRunner runner = new ScriptRunner(writer);
        runner.runScript("svn-add-image", imagePath.toString());
    }

    @Override
    public void doPost(HttpServletRequest request,
                       HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

}