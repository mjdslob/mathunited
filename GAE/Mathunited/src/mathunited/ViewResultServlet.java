package mathunited;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import mathunited.configuration.Configuration;
import mathunited.configuration.Repository;
import mathunited.model.Score;
import mathunited.model.User;
import mathunited.model.User.UserRole;
import mathunited.utils.UserException;
import mathunited.utils.Utils;

import org.w3c.dom.Document;

import com.google.appengine.labs.repackaged.org.json.JSONObject;

@SuppressWarnings("serial")
public class ViewResultServlet extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(XSLTbean.class.getName());
    private final static int VERSION = 8;
    ServletContext context;
    
    @Override
    public void init(ServletConfig config) throws ServletException {
        try{
            super.init(config);
            // parse the xslt transforms
            context = getServletContext();
        } catch(Exception e) {
        	LOGGER.severe((new StringBuilder("Init of ViewServlet failed")).append(e.getMessage()).toString());
        }
    }

    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        try{
            Configuration config = Configuration.getInstance(context);
            
            //read request parameters
            @SuppressWarnings("unchecked")
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
            parameterMap.put("repo", repo);
           	if(repo==null)
           		throw new Exception("Het verplichte argument 'repo' ontbreekt: "+repo);
            Repository repository = config.getRepos().get(repo);
            if(repository==null) {
                throw new Exception("Onbekende repository: "+repo);
            }
            
            // -- BEGIN HACK --
            // Would be better to use the same repo for the qti player, but to prevent republishing all qti content for now translate the basic repo 
            // to the qti repo name (DdJ 14-06-2015)
            if (repo.equals("studiovo"))
                parameterMap.put("qtirepo", "ster");
            else if (repo.equals("studiovo_concept"))
            	parameterMap.put("qtirepo", "studiovo_concept");
            // -- END HACK --

            String variant = parameterMap.get("variant");
            if(variant==null) {
                variant = repository.defaultResultVariant;
                if(variant==null || variant.isEmpty()) {
                    throw new Exception("Geef aan welke layout (defaultResultVariant setting of variant parameter) gebruikt dient te worden");
                }
            }
            
            String loginVariant = parameterMap.get("loginVariant");
            if(loginVariant==null) {
            	loginVariant = repository.defaultLoginVariant;
                if(loginVariant==null || loginVariant.isEmpty()) {
                    throw new Exception("Geef aan welke login layout (defaultLoginVariant setting of loginVariant parameter) gebruikt dient te worden");
                }
            }

            String threadid = parameterMap.get("threadid");
           	if(threadid==null)
           		throw new Exception("Het verplichte argument 'threadid' ontbreekt: "+repo);

           	String viewid = parameterMap.get("viewid");

           	String logintoken = parameterMap.get("logintoken");
           	String userid = Utils.userIdFromLoginToken(logintoken);
           	parameterMap.put("userid", userid);
           	String userrole = Utils.userRoleFromLoginToken(logintoken);
           	// TESTCODE testcode which enables us to vary the role we are using to register
           	if (parameterMap.containsKey("userrole") && parameterMap.get("userrole").length() > 0)
           		userrole = parameterMap.get("userrole"); 
           	// END TESTCODE 
           	String schoolcode = Utils.userSchoolFromLoginToken(logintoken);
           	// TESTCODE testcode which enables us to vary the school we are using to register
           	if (parameterMap.containsKey("schoolcode") && parameterMap.get("schoolcode").length() > 0)
           		schoolcode = parameterMap.get("schoolcode"); 
           	// END TESTCODE 

            //ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
            response.setContentType("text/html");
            
            //byte[] result = byteStream.toByteArray();

           	User user = User.load(userid, repository);
           	User viewUser = null;
           	if (viewid != null && viewid.length() > 0)
           		viewUser = User.load(viewid, repository);
            
            // show results page immediately for registered students or entree accounts
            if (userid == null || userid.isEmpty())
            	renderLoginMessagePage(repository, threadid, loginVariant, viewid, response);
//            	response.sendRedirect("/loginmessage.html?v=" + VERSION);
            else if (user != null && user.isTeacher() && viewid == null)
            	response.sendRedirect("/viewclasses.jsp?logintoken=" +  URLEncoder.encode(logintoken, "UTF-8") + "&repo=" + repo + "&threadid=" + threadid);
            else if ((user != null && user.isRegistered()) || userrole == null || userrole.isEmpty() || userrole.equals("affiliate")) {
                parameterMap.put("registered", user != null && user.isRegistered() ? "1" : "0");
                String username = "";
                if (viewUser == null) {
                	if (user != null)
                		username = user.fullName();
                }
                else
                	username = viewUser.fullName();
                parameterMap.put("username", username);
            	renderResultPage(repository, threadid, variant, userid, viewid, response, parameterMap);
            }
            else if (user == null || !user.isRegistered())
            {
            	user = new User();
            	user.id = userid;
            	if (userrole.equals("student"))
            		user.role = UserRole.Student;
            	else if (userrole.equals("staff"))
            		user.role = UserRole.Teacher;
            	else if (userrole.equals("employee"))
            		user.role = UserRole.Teacher;
            	else
               		throw new Exception("Ongeldige waarde voor 'userrole': " + userrole);
            	user.schoolcode = schoolcode;
            	user.save(repository);
            	
            	response.sendRedirect("/registeruser.jsp?v=" + VERSION + "&logintoken=" + URLEncoder.encode(logintoken, "UTF-8") + "&repo=" + repo + "&threadid=" + threadid);
            }
            else
            {
            	throw new UserException("Don't know that to do.<br><br>user=" + (user == null ? "null" : "loaded"));
            }
            	
        }
        catch (Exception e) {
            ServletOutputStream os = response.getOutputStream();
            response.setContentType("text/html");
            os.println("<html><head></head><body><h1>Fout opgetreden</h1><p>");
            os.println(e.getMessage());
            os.println("</p></body></html>"); 
            os.flush();
            os.close();
            throw new ServletException(e);
        }

    }
    
    private void renderLoginMessagePage(Repository repository, String threadid, String variant, String viewid, HttpServletResponse response) throws Exception 
    {
        Configuration config = Configuration.getInstance(context);
        XSLTbean processor = new XSLTbean(context, config.getLoginVariants());

        Document inputDoc = Utils.getResultStrucureXml(repository, "result-structure/" + threadid);
        
        ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
//      ContentResolver resolver = new ContentResolver(repo, sub.file, context);
        ContentResolver resolver = null;
        Map<String, String> parameterMap = new HashMap<String, String>();
        processor.process(new DOMSource(inputDoc), variant, parameterMap, resolver, byteStream);
        response.setContentType("text/html");
        
        byte[] result = byteStream.toByteArray();
//        response.setContentLength(result.length);
        ServletOutputStream os = response.getOutputStream();
        os.write(result);

        os.flush();
        os.close();
    }
    
    private void renderResultPage(Repository repository, String threadid, String variant, String userid, String viewid, HttpServletResponse response, Map<String, String> parameterMap) throws Exception
    {
        Configuration config = Configuration.getInstance(context);
        XSLTbean processor = new XSLTbean(context, config.getResultVariants());

        Document inputDoc = Utils.getResultStrucureXml(repository, "result-structure/" + threadid);

        // TEST CODE
//        DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
//  	    DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
//  	    InputSource is = new InputSource(context.getResourceAsStream("/sources_studiovo/result-test.xml"));
//  	    inputDoc = dBuilder.parse(is);
  	    // END TEST CODE
        
    	HashMap<Integer, Integer> eindExamenSiteItems = Utils.getEindExamenSiteItems(inputDoc);
    	HashMap<String, Integer> qtiPlayerItems = Utils.getQtiPlayerItems(inputDoc);
        
    	if (viewid == null || viewid.equals(""))
    		viewid = userid;
    	
        Map<String, Score> results = new HashMap<String, Score>();
        if (eindExamenSiteItems.size() > 0)
        	Utils.getEindExamenSiteResults(eindExamenSiteItems, viewid, results);
        if (qtiPlayerItems.size() > 0)
        	Utils.getQtiPlayerResults(qtiPlayerItems, viewid, results);
		Document outputDoc = Utils.transformResults(inputDoc, results);
		
        ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
//        ContentResolver resolver = new ContentResolver(repo, sub.file, context);
        ContentResolver resolver = null;
        DOMSource xmlSource = new DOMSource(outputDoc); 
        processor.process(xmlSource, variant, parameterMap, resolver, byteStream);
        response.setContentType("text/html");
        
        byte[] result = byteStream.toByteArray();
//        response.setContentLength(result.length);
        ServletOutputStream os = response.getOutputStream();
        os.write(result);

    	os.println("<!--");
        os.println("eindExamenSiteItems count: " + eindExamenSiteItems.size() + "; result count: " + results.size() + "; ");
        os.println("returned values:");
        for (Map.Entry<String, Score> entry : results.entrySet()) {
        	os.println(entry.getKey() + " : " + entry.getValue().score + "/" + entry.getValue().total);
    	}
        
    	TransformerFactory tf = TransformerFactory.newInstance();
    	Transformer transformer = tf.newTransformer();
    	transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
    	StringWriter writer = new StringWriter();
    	transformer.transform(new DOMSource(outputDoc), new StreamResult(writer));
    	os.println(writer.getBuffer().toString());
        os.println("-->");
        
        
        os.flush();
        os.close();
    }
    
	public static String executeHttpPostStringResult(String url, JSONObject jsonObject) throws Exception
    {
    	HttpURLConnection con = (HttpURLConnection) new URL(url).openConnection();
    	con.setDoOutput(true);
    	con.setDoInput(true);
    	con.setRequestMethod("POST");
		con.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
		con.setRequestProperty("Accept", "application/json");
		con.setRequestProperty("Content-Type", "application/json; charset=utf8");
		//con.setRequestProperty("Authorization", "Basic " + Base64.encodeToString((MpwSettings.serviceAuthenticationUser + ":" + MpwSettings.serviceAuthenticationPass).getBytes(), Base64.NO_WRAP));    

		OutputStream os = con.getOutputStream();
		os.write(jsonObject.toString().getBytes("UTF-8"));
		os.close();
		
		int httpResult =con.getResponseCode(); 
		if (httpResult != HttpURLConnection.HTTP_OK)
			throw new Exception("Cannot connect to url " + url); 
			
        BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "utf-8"));  

	    String line = null;  
	    StringBuilder sb = new StringBuilder(); 
	 
		while ((line = br.readLine()) != null) {  
		    sb.append(line + "\n");  
		}  

	    br.close();  

	    return sb.toString();
    }

    public static JSONObject executeHttpPostResult(String url, JSONObject jsonObject) throws Exception
    {
    	return new JSONObject(executeHttpPostStringResult(url, jsonObject));
    }
    
    public boolean isMobile(String uaStr) {
    	boolean ismobile = false;
    	if(uaStr.contains("iPad") || uaStr.contains("Android")) ismobile = true;
    	return ismobile;
    }
    
    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
 
    	try
    	{
	    	String repo = request.getParameter("repo");
	    	String logintoken = request.getParameter("logintoken");
	    	String userid = Utils.userIdFromLoginToken(logintoken);
	    	String threadid = request.getParameter("threadid");
	    	
	        Configuration config = Configuration.getInstance(context);
	        Repository repository = config.getRepos().get(repo);
	        if(repository==null) {
	            throw new Exception("Onbekende repository: "+repo);
	        }
	        
	        User user = User.load(userid, repository);
	        if (user == null)
	        	throw new Exception("Gebruiker niet teruggevonden in database");
	
	        user.firstName = request.getParameter("firstName");
	        user.lastNamePrefix = request.getParameter("lastNamePrefix");
	        user.lastName = request.getParameter("lastName");
	        user.email = request.getParameter("email");
	        user.save(repository);

	        response.sendRedirect("/viewclasses.jsp?logintoken=" +  URLEncoder.encode(logintoken, "UTF-8") + "&repo=" + repo + "&threadid=" + threadid);
    	}
        catch (Exception e) {
            ServletOutputStream os = response.getOutputStream();
            response.setContentType("text/html");
            os.println("<html><head></head><body><h1>Fout opgetreden</h1><p>");
            os.println(e.getMessage());
            os.println("</p></body></html>");
            os.flush();
            os.close();
            throw new ServletException(e);
        }
    }
}