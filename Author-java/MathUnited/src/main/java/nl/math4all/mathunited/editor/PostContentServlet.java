package nl.math4all.mathunited.editor;

import java.io.*;
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
import org.w3c.dom.Element;
import javax.xml.xpath.*;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.NodeList;
import nl.math4all.mathunited.XSLTbean;
import nl.math4all.mathunited.exceptions.LoginException;
import nl.math4all.mathunited.configuration.*;
import nl.math4all.mathunited.configuration.SubComponent;
import nl.math4all.mathunited.configuration.Component;
import nl.math4all.mathunited.resolvers.ContentResolver;
import nl.math4all.mathunited.utils.UserManager;
import nl.math4all.mathunited.utils.FileManager;


//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class PostContentServlet extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(PostContentServlet.class.getName());
    private String resultXML = "<post result=\"{#POSTRESULT}\"><message>{#MESSAGE}</message></post>";
    XSLTbean processor;
    Map<String, Component> componentMap;
    ServletContext context;

    @Override
    public void init(ServletConfig config) throws ServletException {
        try{
            super.init(config);
            LOGGER.setLevel(Level.INFO);
            context = getServletContext();

            processor = new XSLTbean(context);
        } catch(Exception e) {
            System.out.println(e.getMessage());
        }
    }


    @Override
    public void doPost ( HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/xml");
        Writer w = response.getWriter();
        PrintWriter pw = new PrintWriter(w);
        try{
            //check if user is logged in
            Configuration config = Configuration.getInstance();
            String repoId=null;
            Cookie[] cookieArr = request.getCookies();
            if(cookieArr != null) {
                for(Cookie c:cookieArr) {
                    String name = c.getName();
                    if(name.equals("REPO")) {
                        repoId = c.getValue();
                    }
                }
            }
            if(repoId==null) {
                throw new Exception("Repository is not set.");
            }
            UserSettings usettings = UserManager.isLoggedIn(request,response);
            
            String body = readBody(request);
            
            BufferedReader br = new BufferedReader(new StringReader(body));
            String _repo = br.readLine(); //not used
            String comp = br.readLine();
            String subcomp = br.readLine();
            String status = br.readLine();
            String nItemsStr = br.readLine();
            int nItems = 0;
            if(nItemsStr!=null) nItems = Integer.parseInt(nItemsStr);
            
            StringBuffer htmlBuffer = new StringBuffer();
            String sCurrentLine;
            while ((sCurrentLine = br.readLine()) != null) {
	         htmlBuffer.append(sCurrentLine);
            }
            String html = htmlBuffer.toString();
            if(comp==null) {
                throw new Exception("Het verplichte argument 'comp' ontbreekt.");
            } 
            if(subcomp==null) {
                throw new Exception("Het verplichte argument 'subcomp' ontbreekt.");
            } else {subcomp=subcomp.trim();}
            if(repoId==null) {
                throw new Exception("Het verplichte argument 'repo' ontbreekt.");
            }
            if(html==null) {
                throw new Exception("Het verplichte argument 'html' ontbreekt.");
            }
            Map<String, String> parameterMap = new HashMap<String, String>();
            parameterMap.put("comp", comp);
            parameterMap.put("subcomp", subcomp);
            parameterMap.put("repo", repoId);
            parameterMap.put("html", html);
                        
            
            LOGGER.log(Level.INFO, "Commit: user={0}, comp={1}, subcomp={2}, repo={3}", new Object[]{usettings.mail, comp, subcomp, repoId});
            LOGGER.log(Level.FINE, html);
            Repository repository = config.getRepos().get(repoId);
            if(repository==null) {
                throw new Exception(repoId+" is een ongeldige repository");
            }
            boolean access = false;
            for(String role : usettings.roles) {
                if(role.equals(repository.edit_permission)) {
                    access = true;
                    break;
                }
            }
            if(!access) throw new LoginException("You do not have the rights to edit repository "+repoId);

            //user has access, continue

            //read components. To be moved to init()
            componentMap = repository.readComponentMap();
            Component component = componentMap.get(comp);
            if(component==null) {
                throw new Exception("Er bestaat geen component met id '"+comp+"'");
            }

            // find subcomponent, previous and following
            SubComponent sub=null;
            boolean found = false;
            for(int ii=0; ii<component.subComponentList.size(); ii++ ){
                sub = component.subComponentList.get(ii);
                if(sub.id.equals(subcomp)) {
                    found=true;
                    break;
                }
            }
            
            if(sub==null || !found) {
                throw new Exception("Er bestaat geen subcomponent met id '"+subcomp+"'");
            }

            LOGGER.log(Level.FINE, "found subcomponent {0}: {1}", new Object[]{subcomp, sub.title});
            XMLReader xmlReader = XMLReaderFactory.createXMLReader("org.ccil.cowan.tagsoup.Parser");
            xmlReader.setFeature(org.ccil.cowan.tagsoup.Parser.namespacesFeature, false);
            xmlReader.setEntityResolver(ContentResolver.entityResolver);
            
            int ind = sub.file.lastIndexOf('/');
            String subFolder = sub.file.substring(0, ind);
            String refbase = config.getContentRoot()+repository.getPath()+"/"+subFolder+"/";

            ContentResolver resolver = new ContentResolver(repository, context);
            StringReader strReader = new StringReader(html);
            InputSource xmlSource = new InputSource(strReader);
            SAXSource xmlSaxSource = new SAXSource(xmlReader, xmlSource);

            Node root = processor.processToDOM(xmlSaxSource, "m4a_inverse", parameterMap, resolver);

            /*
            File subcompFile = new File(refbase);
            if(!FileManager.backupFolderExists(subFolder, repository)) {
                LOGGER.log(Level.FINE, "Creating initial backup: subFolder={0}", new Object[]{subFolder});
                File zipFile = FileManager.backupSubcomponent("original",subFolder, repository);
                FileManager.log(subFolder, usettings.username, zipFile, repository);
            }
            */
            
            XPath xpath = XPathFactory.newInstance().newXPath();
            String expression = "//include";
            NodeList nodes = (NodeList) xpath.evaluate(expression, root, XPathConstants.NODESET);
            int n = nodes.getLength();
            if(n!=nItems) {                
                LOGGER.log(Level.SEVERE, "Number of items does not match. Expected {0}, but found {1}. Not saving the document to prevent loss of content.", new Object[]{nItems, n});
                saveState(html,comp, subcomp, nItems,n, repository);
                String result = resultXML.replace("{#POSTRESULT}","false").replace("{#MESSAGE}", "Number of items does not match. Not saving the document to prevent loss of content.");
                pw.println(result);
            } else {
                for(int ii=0; ii<n; ii++) {
                    Node node = nodes.item(ii);
                    NamedNodeMap nodeMap = node.getAttributes();
                    if(nodeMap!=null) {
                        Node attrNode = nodeMap.getNamedItem("filename");
                        if(attrNode!=null) {
                            String fileStr = refbase + attrNode.getNodeValue();
                            if(node.getFirstChild()!=null) {
                                FileManager.writeToFile(fileStr, node.getFirstChild(), repository);
                                node.removeChild(node.getFirstChild());
                            } 
                        }
                    }
                }
                //store master file
                expression = "/root/subcomponent";
                Element node = (Element) xpath.evaluate(expression, root, XPathConstants.NODE);
                node.setAttribute("status", status);
                String fileStr = config.getContentRoot()+repository.getPath()+"/" + sub.file;
                FileManager.writeToFile(fileStr, node, repository);
                WorkflowServlet.updateStatus(repoId, subcomp, fileStr);

                //create backup
                /*
                File zipFile = FileManager.backupSubcomponent(null,subFolder, repository);
                FileManager.log(subFolder, usettings.username, zipFile, repository);
                */

                String result = resultXML.replace("{#POSTRESULT}","true").replace("{#MESSAGE}", "success");
                pw.println(result);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            String result = resultXML.replace("{#POSTRESULT}","false").replace("{#MESSAGE}", e.getMessage());
            pw.println(result);
        }
        
    }
    
    private void saveState(String html, String comp, String subcomp, int nItems, int n, Repository repo) throws Exception {
        Configuration config = Configuration.getInstance();
        File f = new File(config.contentRoot+repo.getPath()+"/debug/"+comp+"/"+subcomp+"/log.txt");
        f.getParentFile().mkdirs();
        BufferedWriter out = new BufferedWriter(new FileWriter(f));
        out.write("\n----------------\n");
        out.write("nItems in html = "+nItems+", nItems in xml ="+n);
        out.write("\n----------------\n");
        out.write(html);
        out.write("\n----------------\n");
        out.close();
    }
    
    @Override
    public void doGet (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {

    }
    
    private String readBody(HttpServletRequest request) throws Exception {
        int length = request.getContentLength();
        BufferedReader br = request.getReader();
        char[] buffer = new char[4*1024];
        int numChars;
        StringBuilder result = new StringBuilder();
        
        while( (numChars=br.read(buffer,0,buffer.length)) >=0 ) {
            result.append(buffer,0,numChars);
        }

        String str = result.toString();
        int nRead = str.getBytes().length;
        if(nRead!=length) {
            LOGGER.log(Level.SEVERE, "Number of bytes read does not match contextlength header. Nr of bytes read = {0}, content-length = {1}", new Object[]{nRead, length});
            if(nRead<length*0.9)
                throw new Exception("Number of bytes read does not match contextlength header. Nr of bytes read = "+nRead+", content-length = "+length);
        } else {
            LOGGER.log(Level.FINE, "sanity check passed: number of bytes in body matches contentlength header: {0}", length);
        }
        
        return str;
    }
}