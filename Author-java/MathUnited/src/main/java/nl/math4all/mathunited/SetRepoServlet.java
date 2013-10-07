package nl.math4all.mathunited;

import java.io.*;
import java.net.URLDecoder;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.Map;
import java.util.HashMap;
import javax.xml.transform.sax.SAXSource;
import org.xml.sax.InputSource;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;
import org.w3c.dom.Node;
import javax.xml.xpath.*;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.NodeList;
import java.nio.channels.FileChannel;
import org.w3c.dom.bootstrap.DOMImplementationRegistry;
import org.w3c.dom.Document;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSSerializer;
import org.w3c.dom.ls.LSOutput;
import org.w3c.dom.DOMConfiguration;
import org.w3c.dom.DOMError;
import org.w3c.dom.DOMErrorHandler;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import nl.math4all.mathunited.exceptions.LoginException;
import nl.math4all.mathunited.configuration.*;
import nl.math4all.mathunited.configuration.SubComponent;
import nl.math4all.mathunited.configuration.Component;
import nl.math4all.mathunited.resolvers.ContentResolver;
import nl.math4all.mathunited.utils.UserManager;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class SetRepoServlet extends HttpServlet {
    private String resultXML = "<setrepo result=\"{#POSTRESULT}\"><message>{#MESSAGE}</message></setrepo>";


    @Override
    public void doGet ( HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/xml");
        Writer w = response.getWriter();
        PrintWriter pw = new PrintWriter(w);
        try{
            //check if user is logged in
            Configuration config = Configuration.getInstance();
            UserSettings usettings = UserManager.isLoggedIn(request, response);
            
            String repo = request.getParameter("repo");
            if(repo==null) {
                throw new Exception("Het verplichte argument 'repo' ontbreekt.");
            }

            Repository repository = config.getRepos().get(repo);
            if(repository==null) {
                throw new Exception(repo+" is een ongeldige repository");
            }
            Cookie cookie = new Cookie("REPO", repo);
            cookie.setMaxAge(24*60*60);
            response.addCookie(cookie);
            
            String result = resultXML.replace("{#POSTRESULT}","true").replace("{#MESSAGE}", "success");
            pw.println(result);
        }
        catch (Exception e) {
            e.printStackTrace();
            String result = resultXML.replace("{#POSTRESULT}","false").replace("{#MESSAGE}", e.getMessage());
            pw.println(result);
        }
        
    }
    
 
    
    
}