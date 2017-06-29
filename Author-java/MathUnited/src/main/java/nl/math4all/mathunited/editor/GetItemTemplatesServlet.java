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
import javax.xml.xpath.XPathFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import nl.math4all.mathunited.utils.FileManager;
import nl.math4all.mathunited.utils.Utils;

//used to generate new items (examples, exercises, etc)
// - read templates for new items from /webapp/content-items/<item-file>
// - optionally include item from clipboard, if such an item is available (and is compatible with requested item type)
public class GetItemTemplatesServlet extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(GetItemTemplatesServlet.class.getName());

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        LOGGER.setLevel(Level.FINE);
    }

    @Override
    public void doGet (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {
        
        try{
            Configuration config = Configuration.getInstance();
            UserSettings usettings = UserManager.isLoggedIn(request);
            String typestr = Utils.readParameter("type", true, request);
            
            //read request parameters
            Map<String, String> parameterMap = Utils.readParameters(request);

            //LOGGER.log(Level.FINE, "GetItemTemplatesServlet: type={0}", typestr);

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
            //LOGGER.log(Level.FINE, "Reading content-items from {0}", fname);
            InputStream xmlStream = getServletContext().getResourceAsStream(fname);
            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
	    Document doc = dBuilder.parse(xmlStream);
            doc.getDocumentElement().normalize();
            //get compatible components
            XPathFactory xPathfactory = XPathFactory.newInstance();
            XPath xpath = xPathfactory.newXPath();
            XPathExpression expr = xpath.compile("//container[@name=\"" + typestr + "\"]");
            Node containerNode = (Node)expr.evaluate(doc, XPathConstants.NODE);

            response.setContentType("application/xml");
            if(containerNode==null) {
                //LOGGER.log(Level.FINE,"Could not find templates for type={0}", typestr);
                Writer w = response.getWriter();
                PrintWriter pw = new PrintWriter(w);
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
                //LOGGER.log(Level.FINE, "GetItemTemplatesServlet: result={0}", result);
                byte[] barr = result.getBytes("UTF-8");
                response.setCharacterEncoding("UTF-8");
                response.setContentLength(barr.length);
                ServletOutputStream os = response.getOutputStream();
                os.write(barr);
            }
        }
        catch (Exception e) {
            System.out.println(Utils.echoContext(request, "ERROR"));
            LOGGER.severe(e.getMessage());
            Utils.writeError(response, e);
        }

    }
    
    @Override
    public void doPost (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {
        //get the pdf from the session and return it
    }

}