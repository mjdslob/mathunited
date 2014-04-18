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
import static nl.math4all.mathunited.resolvers.ContentResolver.entityResolver;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class ProcessItemServlet extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(ProcessItemServlet.class.getName());
    XSLTbean processor;
    Map<String, Component> componentMap;
    ServletContext context;
    Properties prop = new Properties();
    
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
            if(isMobile(request.getHeader("user-agent"))) {
                parameterMap.put("is_mobile", "true");
            } else {
                parameterMap.put("is_mobile", "false");
            }

            String comp = parameterMap.get("comp");
            String subcomp = parameterMap.get("subcomp");            
            String variant = parameterMap.get("variant");    
            String xmlstr = parameterMap.get("xml");            
            LOGGER.log(Level.FINE, "processitem: comp={0}, subcomp={1}, xml={2}", new Object[]{comp, subcomp, xmlstr});
            if(comp==null) {
                throw new Exception("Het verplichte argument 'comp' ontbreekt.");
            }
            
            if(subcomp==null) {
                throw new Exception("Het verplichte argument 'subcomp' ontbreekt.");
            }
            
            if(variant==null) {
                throw new Exception("Het verplichte argument 'variant' ontbreekt.");
            }

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
            Map<String, Repository> repoMap = config.getRepos();
            Repository repository = repoMap.get(repo);
            if(repository==null) {
                throw new Exception("Onbekende repository: "+repo);
            }
            Repository baserepo = null;
            if(repository.baseRepo!=null) {
                baserepo = repoMap.get(repository.baseRepo);
            }
            
            //read components. To be moved to init()
            File f = new File(config.contentRoot+repository.getPath()+"/leerlijnen/components.xml");
            if(!f.exists() && !repository.baseRepo.isEmpty()) {
                Repository baseRepo = config.getRepos().get(repository.baseRepo);
                f = new File(config.contentRoot+baseRepo.getPath()+"/leerlijnen/components.xml");
            }
            FileInputStream is = new FileInputStream(f);
            componentMap = Component.getComponentMap(new InputSource(is));
            
            Component component = componentMap.get(comp);
            if(component==null) {
                throw new Exception("Er bestaat geen component met id '"+comp+"'");
            }
            
            
            //if subcomp is not an integer, it will be interpreted as the index of the subcomponent.
            //note: this implies that an id of a subcomponent can not be an integer!
            try{
                int subcomp_index = Integer.parseInt(subcomp);
                if(subcomp_index>0 && subcomp_index<=component.subComponentList.size()){
                    SubComponent sub = component.subComponentList.get(subcomp_index-1);
                    subcomp = sub.id;
                }
            } catch(NumberFormatException exc) {
                
            }
            
            
            // find subcomponent, previous and following
            SubComponent sub=null, nextSub=null, prevSub=null;
            int subcomp_index = 0;
            for(subcomp_index=0; subcomp_index<component.subComponentList.size(); subcomp_index++ ){
                sub = component.subComponentList.get(subcomp_index);
                if(sub.id.equals(subcomp)) {
                    if(subcomp_index>0) prevSub = component.subComponentList.get(subcomp_index-1);
                    if(subcomp_index<component.subComponentList.size()-1) nextSub = component.subComponentList.get(subcomp_index+1);
                    break;
                }
            }
            if(sub==null) {
                throw new Exception("Er bestaat geen subcomponent met id '"+subcomp+"'");
            }
            
            // supply path to subcomponent to xslt. Might be needed when resolving other xml-documents
            int ind = sub.file.lastIndexOf('/');
            parameterMap.put("refbase", repository.getPath()+"/"+sub.file.substring(0, ind+1));
            parameterMap.put("component", component.getXML());
            parameterMap.put("repo-path", repository.getPath());
            parameterMap.put("baserepo-path", baserepo==null?"":baserepo.getPath());
            parameterMap.put("option","editor-process-item");
            parameterMap.put("dopreprocess","true()");  //used to remove xhtml namespaces that are added by TagSoup parser
            ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
            ContentResolver resolver = new ContentResolver(repo, context);
            
            LOGGER.log(Level.FINE, "process-item: xml={0}", xmlstr);
            XMLReader xmlReader = XMLReaderFactory.createXMLReader("org.apache.xerces.parsers.SAXParser");
            xmlReader.setEntityResolver(ContentResolver.entityResolver);
            StringReader reader = new StringReader(xmlstr);
            InputSource xmlSource = new InputSource(reader);
            SAXSource xmlSaxSource = new SAXSource(xmlReader, xmlSource);
            
            String errStr = processor.process(xmlSaxSource, variant, parameterMap, resolver, byteStream);
            response.setContentType("text/html");
            if(errStr.length()>0){
                PrintWriter writer = response.getWriter();
                String resultStr = "<html><head></head><body>"+errStr+"</body></html>";
                writer.println(resultStr);
            } else {
                byte[] result = byteStream.toByteArray();
                response.setContentLength(result.length);
                ServletOutputStream os = response.getOutputStream();
                os.write(result);
            }

        }
        catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html");
            Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            pw.println("<html><head></head><body><h1>Fout opgetreden</h1><p>");
            pw.println(e.getMessage());
            pw.println("</p></body></html>");
//            throw new ServletException(e);
        }

    }

    public boolean isMobile(String uaStr) {
        if(uaStr==null) return false;
    	boolean ismobile = false;
    	if(uaStr.contains("iPad") || uaStr.contains("Android")) ismobile = true;
    	
    	return ismobile;
    }
    
    @Override
    public void doGet (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {
        //get the pdf from the session and return it
    }

}