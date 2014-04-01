package mathunited;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import mathunited.configuration.Component;
import mathunited.configuration.SubComponent;
import mathunited.configuration.Configuration;
import mathunited.configuration.Repository;
import javax.xml.transform.Source;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.PreparedQuery;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Query.FilterPredicate;
import com.google.appengine.api.datastore.Text;

import java.util.Map;
import java.util.HashMap;
import java.util.logging.Logger;

@SuppressWarnings("serial")
public class ViewResultServlet extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(XSLTbean.class.getName());
    XSLTbean processor;  
    ServletContext context;
    
    @Override
    public void init(ServletConfig config) throws ServletException {
        try{
            super.init(config);
            // parse the xslt transforms
            context = getServletContext();
            processor = new XSLTbean(context);
        } catch(Exception e) {
        	LOGGER.severe((new StringBuilder("Init of ViewServlet failed")).append(e.getMessage()).toString());
        }
    }

    @Override
    public void doGet (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {

        try{
            Configuration config = Configuration.getInstance(context);

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
            
            String repo = parameterMap.get("repo");
           	if(repo==null)
           		throw new Exception("Het verplichte argument 'repo' ontbreekt: "+repo);
            Repository repository = config.getRepos().get(repo);
            if(repository==null) {
                throw new Exception("Onbekende repository: "+repo);
            }
            
            String threadid = parameterMap.get("threadid");
           	if(threadid==null)
           		throw new Exception("Het verplichte argument 'threadid' ontbreekt: "+repo);
           	
            parameterMap.put("repo", repo);
            ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
            response.setContentType("text/html");
            
            //byte[] result = byteStream.toByteArray();
            
            String xml = getResultStrucureXml(repository, "result-structure/" + threadid);
            if (xml == null)
            	throw new Exception("Structuur xml met id " + "result-structure/" + threadid + " niet gevonden");
            response.setContentLength(xml.length());
            response.getOutputStream().write(xml.getBytes());
            response.getOutputStream().flush();
            response.getOutputStream().close();
        }
        catch (Exception e) {
            e.printStackTrace(response.getWriter());
            response.setContentType("text/html");
            Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            pw.println("<html><head></head><body><h1>Fout opgetreden</h1><p>");
            pw.println(e.getMessage());
            pw.println("</p></body></html>");
            throw new ServletException(e);
        }

    }
    
    private String getResultStrucureXml(Repository repository, String id) throws EntityNotFoundException
    {
	   DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

	   Key repoKey = KeyFactory.createKey("Repository", repository.id);
	   Key key = KeyFactory.createKey(repoKey, "XmlFile", id);
	   Entity entity = datastore.get(key);
	   Text textProp = (Text)entity.getProperty("text");
	   return textProp.getValue();
    }
    
    public boolean isMobile(String uaStr) {
    	boolean ismobile = false;
    	if(uaStr.contains("iPad") || uaStr.contains("Android")) ismobile = true;
    	return ismobile;
    }
    
    @Override
    public void doPost (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {
        //get the pdf from the session and return it
    }

}