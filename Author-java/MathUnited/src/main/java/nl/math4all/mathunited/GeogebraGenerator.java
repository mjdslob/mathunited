package nl.math4all.mathunited;

import nl.math4all.mathunited.configuration.Component;
import java.io.*;
import java.net.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.Map;
import java.util.HashMap;
import nl.math4all.mathunited.resolvers.ContentResolver;
import javax.xml.bind.DatatypeConverter;
import nl.math4all.mathunited.configuration.Configuration;
import nl.math4all.mathunited.configuration.Repository;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.Path;


//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class GeogebraGenerator extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(GeogebraGenerator.class.getName());
    String ggbSource = "http://www.geogebra.org/web/4.2/web/web.nocache.js";
//    String ggbSource = "http://js.geogebra.at/web/web.nocache.js";
//    String ggbSource = "http://www.geogebratube.org/scripts/deployggb.js";
    @Override
    public void init(ServletConfig config) throws ServletException {
         super.init(config);
         LOGGER.setLevel(Level.FINE);
    }


    @Override
    public void doGet (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {

        Writer w = response.getWriter();
        PrintWriter pw = new PrintWriter(w);
        try{
            String fname = request.getParameter("file");
            if(fname==null) {
                throw new Exception("Please supply a filename");
            }
            Configuration config = Configuration.getInstance();
            String repo = request.getParameter("repo");
            if(repo==null) {
                throw new Exception("Please supply a repository name");
            }
            Map<String, Repository> repoMap = config.getRepos();
            Repository repository = repoMap.get(repo);
            if(repository==null) {
                throw new Exception("Unknown repository: "+repo);
            }
            String pathstr = config.getContentRoot()+repository.getPath();
            String filestr;
            if(!pathstr.isEmpty() && pathstr.charAt(pathstr.length()-1)!='/') {
                filestr = pathstr+"/"+fname;
            } else {
                filestr = pathstr+fname;                
            }
            LOGGER.log(Level.FINE, "file={0}", filestr);
            Path path = Paths.get(filestr);
            byte[] data = Files.readAllBytes(path);
            String b64 = DatatypeConverter.printBase64Binary(data);
            response.setContentType("text/html");
            pw.println("<html style='overflow:hidden'><head><style type='text/css'><!--body { font-family:Arial,Helvetica,sans-serif; margin-left:40px }--></style><script type='text/javascript' language='javascript' src='"+ggbSource+"'></script></head>");
            pw.println("<body><article class='geogebraweb' style='display:inline-block;' data-param-ggbbase64='"+b64+"'></article>");
            pw.println("<script type='text/javascript'>var ggbApplet = document.ggbApplet;function ggbOnInit() {}</script></body></html>");
        } catch(Exception e) {
            e.printStackTrace();
            pw.println("An error occured: "+e.getMessage());
            LOGGER.severe(e.getMessage());
        }
    }



    @Override
    public void doPost (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {
        //get the pdf from the session and return it
    }

}