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
import nl.math4all.mathunited.utils.FileManager;
import nl.math4all.mathunited.utils.UserManager;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class RemoveItemServlet extends HttpServlet {
    private String resultXML = "<remove result=\"{#RESULT}\"><message>{#MESSAGE}</message></remove>";
    XSLTbean processor;
    Map<String, Component> componentMap;
    ServletContext context;

    @Override
    public void init(ServletConfig config) throws ServletException {
        try{
            super.init(config);
            context = getServletContext();
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
            
            UserSettings usettings = UserManager.isLoggedIn(request, response);
            
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
            String comp = parameterMap.get("comp");
            String subcomp = parameterMap.get("subcomp");
            String item = parameterMap.get("item");
            String itempos = parameterMap.get("position");
            parameterMap.put("repo",repoId);
            if(comp==null) {
                throw new Exception("Het verplichte argument 'comp' ontbreekt.");
            }
            if(subcomp==null) {
                throw new Exception("Het verplichte argument 'subcomp' ontbreekt.");
            }
            if(repoId==null) {
                throw new Exception("Het verplichte argument 'repo' ontbreekt.");
            }
            if(item==null) {
                throw new Exception("Het verplichte argument 'item' ontbreekt.");
            } 
            if(itempos==null) {
                throw new Exception("Het verplichte argument 'position' ontbreekt.");
            } 
            parameterMap.put("item",item);
            parameterMap.put("itempos", itempos);
            
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
            File fcomp = new File(config.contentRoot+repository.path+"/leerlijnen/components.xml");
            if(!fcomp.exists() && !repository.baseRepo.isEmpty()) {
                Repository baseRepo = config.getRepos().get(repository.baseRepo);
                fcomp = new File(config.contentRoot+baseRepo.path+"/leerlijnen/components.xml");
            }
            FileInputStream is = new FileInputStream(fcomp);
            componentMap = Component.getComponentMap(new InputSource(is));
            
            Component component = componentMap.get(comp);
            if(component==null) {
                throw new Exception("Er bestaat geen component met id '"+comp+"'");
            }

            // find subcomponent, previous and following
            SubComponent sub=null;
            for(int ii=0; ii<component.subComponentList.size(); ii++ ){
                sub = component.subComponentList.get(ii);
                if(sub.id.equals(subcomp)) {
                    break;
                }
            }
            if(sub==null) {
                throw new Exception("Er bestaat geen subcomponent met id '"+subcomp+"'");
            }

            
            int ind = sub.file.lastIndexOf('/');
            String refbase = config.getContentRoot()+sub.file.substring(0, ind+1);
            Map<String, Repository> map = config.getRepos();
            Repository def = map.get(repository.baseRepo);
            String altbase = refbase.replace(def.path, repository.path);

            ContentResolver resolver = new ContentResolver(repoId, context);
            SAXSource subcompSource = resolver.resolve(sub.file, "");

            Node root = processor.processToDOM(subcompSource, "m4a_remove", parameterMap, resolver);

            XPath xpath = XPathFactory.newInstance().newXPath();
            String expression = "//remove-include";
            NodeList nodes = (NodeList) xpath.evaluate(expression, root, XPathConstants.NODESET);
            int n = nodes.getLength();
            for(int ii=0; ii<n; ii++) {
                Node node = nodes.item(ii);
                NamedNodeMap nodeMap = node.getAttributes();
                if(nodeMap!=null) {
                    Node attrNode = nodeMap.getNamedItem("filename");
                    if(attrNode!=null) {
                        String fileStr = altbase+attrNode.getNodeValue();
                        File f = new File(fileStr);
                        if(f.exists()) {
                            FileManager.createBackup(f, repository);
                            f.delete();
                        }
                        node.getParentNode().removeChild(node);
                    }
                }
            }
            
            //store master file
            String fileStr = config.getContentRoot()+sub.file;
            fileStr = fileStr.replace(def.path, repository.path);
            FileManager.writeToFile(fileStr, root, repository);
            
            String result = resultXML.replace("{#RESULT}","true").replace("{#MESSAGE}", "success");
            pw.println(result);
        }
        catch (Exception e) {
            e.printStackTrace();
            String result = resultXML.replace("{#RESULT}","false").replace("{#MESSAGE}", e.getMessage());
            pw.println(result);
        }
        
    }
    
    static String createValidFilename(String fname, String refbase, String orgbase) throws Exception {
        int MAXINDEX = 9;
        int index = 1;
        String str = fname.replace("*",""+index);
        File f1 = new File(refbase+str);
        File f2 = new File(orgbase+str);
        while(index<MAXINDEX && (f1.exists()||f2.exists())) {
            index++;
            str = fname.replace("*",""+index);
            f1 = new File(refbase+str);
            f2 = new File(orgbase+str);
        }
        if(index==MAXINDEX) throw new Exception("Maximum inserts reached");
        return str;
    }
    

    @Override
    public void doGet (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {

    }
    
    
}