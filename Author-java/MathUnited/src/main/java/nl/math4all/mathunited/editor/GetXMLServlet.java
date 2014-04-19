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
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;
import org.w3c.dom.Node;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class GetXMLServlet extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(GetXMLServlet.class.getName());
    XSLTbean processor;
    ServletContext context;
    
    @Override
    public void init(ServletConfig config) throws ServletException {
        try{
            super.init(config);
            context = getServletContext();
            LOGGER.setLevel(Level.INFO);
            processor = new XSLTbean(context);
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

            String htmlstr = parameterMap.get("html");            
            if(htmlstr==null) {
                throw new Exception("Het verplichte argument 'html' ontbreekt.");
            }
            LOGGER.log(Level.FINE, "GetXML: html={0}", htmlstr);

            //parse the html into xml with tagsoup parser
            XMLReader xmlReader = XMLReaderFactory.createXMLReader("org.ccil.cowan.tagsoup.Parser");
            xmlReader.setFeature(org.ccil.cowan.tagsoup.Parser.namespacesFeature, false);
            xmlReader.setEntityResolver(ContentResolver.entityResolver);
            StringReader reader = new StringReader(htmlstr);
            InputSource xmlSource = new InputSource(reader);
            SAXSource xmlSaxSource = new SAXSource(xmlReader, xmlSource);
            
            //transform with the inverse-xslt.
            Node root = processor.processToDOM(xmlSaxSource, "m4a_inverse", parameterMap, null);
            response.setContentType("application/xml");
            String result = FileManager.serializeXML(root);
            pw.println( result );
            LOGGER.log(Level.FINE, "GetXML: result={0}", result);
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