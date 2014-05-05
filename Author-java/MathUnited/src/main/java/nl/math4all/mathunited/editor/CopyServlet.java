package nl.math4all.mathunited.editor;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.Map;
import java.util.HashMap;
import javax.xml.transform.Source;
import org.xml.sax.InputSource;
import java.util.Properties;
import javax.xml.transform.sax.SAXSource;
import nl.math4all.mathunited.XSLTbean;
import nl.math4all.mathunited.resolvers.ContentResolver;
import nl.math4all.mathunited.configuration.*;
import nl.math4all.mathunited.configuration.SubComponent;
import nl.math4all.mathunited.configuration.Component;
import nl.math4all.mathunited.exceptions.LoginException;
import nl.math4all.mathunited.utils.FileManager;
import nl.math4all.mathunited.utils.UserManager;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;
import org.w3c.dom.Node;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import org.w3c.dom.Document;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class CopyServlet extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(CopyServlet.class.getName());
    ServletContext context;
    
    @Override
    public void init(ServletConfig config) throws ServletException {
        try{
            super.init(config);
            context = getServletContext();
            LOGGER.setLevel(Level.INFO);
        } catch(Exception e) {
            e.printStackTrace();
            LOGGER.log(Level.SEVERE, e.getMessage());
        }
    }

    @Override
    public void doPost (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {
        
        Writer w = response.getWriter();
        PrintWriter pw = new PrintWriter(w);
        try{
            Configuration config = Configuration.getInstance();
            
            //read request parameters
            Map<String, String[]> paramMap = request.getParameterMap();
            Map<String, String> parameterMap = new HashMap<String, String>();
            for(Map.Entry<String, String[]> entry : paramMap.entrySet()) {
                String pname = entry.getKey();
                String[] pvalArr = entry.getValue();
                if(pvalArr!=null && pvalArr.length>0) {
                   parameterMap.put(pname, pvalArr[0]);
                }
            }

            String xmlstr = parameterMap.get("xml");     
            if(xmlstr==null) {
                throw new Exception("Het verplichte argument 'xml' ontbreekt.");
            }
            String typestr = parameterMap.get("type");
            if(typestr==null) {
                throw new Exception("Het verplichte argument 'type' ontbreekt.");
            }
            LOGGER.log(Level.FINE, "CopyServlet: xml={0}, type={1}", new Object[]{xmlstr, typestr});

            UserSettings usettings = UserManager.isLoggedIn(request,response);
            
            //parse string into xml
            InputStream is = new ByteArrayInputStream(xmlstr.getBytes("UTF-16"));
            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
	    Document doc = dBuilder.parse(is);
            
            //store the DOM in the clipboard
            Clipboard clipboard = usettings.getClipboard();
            clipboard.setItem(typestr, doc.getDocumentElement());
            response.setContentType("application/xml");
            pw.println("<?xml version=\"1.0\" encoding=\"utf-8\"?><response success=\"true\"/>");
        }
        catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html");
            pw.println("<html><head></head><body><h1>Fout opgetreden</h1><p>");
            pw.println(e.getMessage());
            pw.println("</p></body></html>");
//            throw new ServletException(e);
        }

    }
    
    @Override
    public void doGet (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {
        //get the pdf from the session and return it
    }

}