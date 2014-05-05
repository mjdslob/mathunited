package nl.math4all.mathunited.editor;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.Map;
import java.util.HashMap;
import nl.math4all.mathunited.configuration.*;
import nl.math4all.mathunited.utils.UserManager;
import org.w3c.dom.Node;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Attr;
import javax.xml.xpath.XPathFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import nl.math4all.mathunited.utils.FileManager;

//used to generate new items (examples, exercises, etc)
// - read templates for new items from /webapp/content-items/<item-file>
// - optionally include item from clipboard, if such an item is available (and is compatible with requested item type)
public class GetItemTemplatesServlet extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(GetItemTemplatesServlet.class.getName());
    ServletContext context;
    
    @Override
    public void init(ServletConfig config) throws ServletException {
        try{
            super.init(config);
            context = getServletContext();
            LOGGER.setLevel(Level.FINE);
        } catch(Exception e) {
            e.printStackTrace();
            LOGGER.log(Level.SEVERE, e.getMessage());
        }
    }

    @Override
    public void doGet (  HttpServletRequest request,
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

            String typestr = parameterMap.get("type");
            if(typestr==null) {
                throw new Exception("Het verplichte argument 'type' ontbreekt.");
            }
            LOGGER.log(Level.FINE, "GetItemTemplatesServlet: type={0}", typestr);

            UserSettings usettings = UserManager.isLoggedIn(request,response);

            //find out which repository to use
            //try to get repo from cookie
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
            if(repo==null) {
                throw new Exception("Er is geen archief geselecteerd.");
            }
            Map<String, Repository> repoMap = config.getRepos();
            Repository repository = repoMap.get(repo);
            if(repository==null) {
                throw new Exception("Onbekende repository: "+repo);
            }

            if(repository.contentItems==null) throw new Exception("No content-items file available");
            String fname = "/content-items/"+repository.contentItems;
            LOGGER.log(Level.FINE, "Reading content-items from {0}", fname);
            InputStream xmlStream = context.getResourceAsStream(fname);
            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
	    Document doc = dBuilder.parse(xmlStream);
            doc.getDocumentElement().normalize();
            //get compatible components
            XPathFactory xPathfactory = XPathFactory.newInstance();
            XPath xpath = xPathfactory.newXPath();
            XPathExpression expr = xpath.compile("//container[@name=\""+typestr+"\"]");
            Node containerNode = (Node)expr.evaluate(doc, XPathConstants.NODE);

            response.setContentType("application/xml");
            if(containerNode==null) {
                LOGGER.log(Level.FINE,"Could not find templates for type={0}", typestr);
                pw.println("<result success=\"false\"/>");
            } else {
                Clipboard clipboard = usettings.getClipboard();
                if(clipboard.type!=null && clipboard.type.equals(typestr)) {
                    //create a new document using xerces, because Saxon does not allow DOM-manipulation
                    org.apache.xerces.dom.DOMImplementationImpl impl = new org.apache.xerces.dom.DOMImplementationImpl();
                    Document newDoc = impl.createDocument(repo, repo, null);
                    Node importedContainerNode = newDoc.importNode(containerNode, true);
                    Element newNode = newDoc.createElement("container-item");
                    newNode.setAttribute("name", "Plak gekopieerd item");
                    importedContainerNode.appendChild(newNode);
                    Node importedNode = newDoc.importNode(clipboard.node, true);
                    newNode.appendChild(importedNode);
                    containerNode = importedContainerNode;
                }
                
                String result = FileManager.serializeXML(containerNode);
                pw.println(result);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            LOGGER.severe(e.getMessage());
            response.setContentType("text/html");
            pw.println("<html><head></head><body><h1>Fout opgetreden</h1><p>");
            pw.println(e.getMessage());
            pw.println("</p></body></html>");
//            throw new ServletException(e);
        }

    }
    
    @Override
    public void doPost (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {
        //get the pdf from the session and return it
    }

}