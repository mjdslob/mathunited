package nl.math4all.mathunited;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.Writer;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
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
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import nl.math4all.mathunited.configuration.Configuration;
import nl.math4all.mathunited.configuration.Repository;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Text;
import com.google.appengine.labs.repackaged.org.json.JSONArray;
import com.google.appengine.labs.repackaged.org.json.JSONException;
import com.google.appengine.labs.repackaged.org.json.JSONObject;

@SuppressWarnings("serial")
public class ViewResultServlet extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(XSLTbean.class.getName());
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
            XSLTbean processor = new XSLTbean(context, config.getResultVariants());
            
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

            String variant = parameterMap.get("variant");
            if(variant==null) {
                variant = repository.defaultResultVariant;
                if(variant==null || variant.isEmpty()) {
                    throw new Exception("Geef aan welke layout (defaultResultVariant setting of variant parameter) gebruikt dient te worden");
                }
            }

            String threadid = parameterMap.get("threadid");
           	if(threadid==null)
           		throw new Exception("Het verplichte argument 'threadid' ontbreekt: "+repo);

           	String userid = parameterMap.get("userid"); // for testing purposes only
           	if (userid == null)
           		userid = "sanderbons";
            parameterMap.put("userid", userid);
           	
            parameterMap.put("repo", repo);
            //ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
            response.setContentType("text/html");
            
            //byte[] result = byteStream.toByteArray();
            
            String xml = getResultStrucureXml(repository, "result-structure/" + threadid);
            if (xml == null)
            	throw new Exception("Structuur xml met id " + "result-structure/" + threadid + " niet gevonden");
            
            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
        	DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
        	InputSource is = new InputSource(new StringReader(xml));
        	Document inputDoc = dBuilder.parse(is);
        	Map<Integer, Score> results = new HashMap<Integer, Score>();
            
        	HashMap<Integer, Integer> eindExamenSiteItems = new HashMap<Integer, Integer>();
        	
        	NodeList itemNodes = inputDoc.getElementsByTagName("item");
        	for (int i=0; i < itemNodes.getLength(); i++)
        	{
        		Element itemElem = (Element)itemNodes.item(i);
        		if (itemElem.getAttribute("source").equals("es"))
        		{
        			int id = Integer.parseInt(itemElem.getAttribute("id"));
        			int total = Integer.parseInt(itemElem.getAttribute("total"));
        			eindExamenSiteItems.put(id, total);
        		}
        	}
            
    		if (eindExamenSiteItems.size() > 0)
        	{
        		getEindExamenSiteResults(eindExamenSiteItems, userid, results);
        	}
        	
    		DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
    		DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
     		
    		Document outputDoc = docBuilder.newDocument();
    		Element rootElement = outputDoc.createElement("assignments");
    		outputDoc.appendChild(rootElement);
    		copyMetaElements(inputDoc, outputDoc, rootElement);
    		
    		Score uniqueTotal = new Score();
    		processGroup(inputDoc.getDocumentElement(), outputDoc, rootElement, results, new Score(), uniqueTotal, new ArrayList<Integer>());
    		rootElement.setAttribute("uniqueScore", Integer.toString(uniqueTotal.score));
    		rootElement.setAttribute("uniqueTotal", Integer.toString(uniqueTotal.total));

            ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
//            ContentResolver resolver = new ContentResolver(repo, sub.file, context);
            ContentResolver resolver = null;
            DOMSource xmlSource = new DOMSource(outputDoc); 
            processor.process(xmlSource, variant, parameterMap, resolver, byteStream);
            response.setContentType("text/html");
            
            byte[] result = byteStream.toByteArray();
            response.setContentLength(result.length);
            ServletOutputStream os = response.getOutputStream();
            os.write(result);

            os.println("<!--");
        	TransformerFactory tf = TransformerFactory.newInstance();
        	Transformer transformer = tf.newTransformer();
        	transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
        	StringWriter writer = new StringWriter();
        	transformer.transform(new DOMSource(outputDoc), new StreamResult(writer));
        	os.println(writer.getBuffer().toString());
            os.println("-->");
            
            
            os.flush();
            os.close();
            
//            response.setContentLength(outputString.length());
//            response.getOutputStream().write(outputString.getBytes());
//            response.getOutputStream().flush();
//            response.getOutputStream().close();
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
    
    private void getEindExamenSiteResults(HashMap<Integer, Integer> eindExamenSiteItems, String userid, Map<Integer, Score> results) throws Exception 
    {
    	// construct input json E.g. {"userid":"sanderbons","assignmentids":[6507,6503,3978]}
    	JSONObject json = new JSONObject();
    	json.put("userid", userid);
    	JSONArray array = new JSONArray();
    	for (Integer id : eindExamenSiteItems.keySet()) {
        	array.put(id);
		}
    	json.put("assignmentids", array);
    	// execute webservice
    	JSONObject result = executeHttpPostResult("http://www.eindexamensite.nl/GetUserResults/services.html", json);
    	// get result json
    	JSONArray assignments = result.getJSONArray("assignments");
    	
    	for (int i = 0; i < assignments.length(); i++)
    	{
    		JSONObject assignment = assignments.getJSONObject(i);
    		int id = assignment.getInt("id");
    		Score score = new Score();
    		String scoreString = assignment.getString("score");
    		if (!scoreString.equals("null"))
    			score.score = Integer.parseInt(scoreString);
       		String totalString = assignment.getString("total");
    		if (!totalString.equals("null"))
    		{
    			score.total = Integer.parseInt(totalString);
    			score.made = true;
    		}
    		else
    		{
    			score.total = eindExamenSiteItems.get(id);
    			score.made = false;
    		}
    		results.put(id, score);
    	}
    }
    
    private void processGroup(Element inputElem, Document outputDoc, Element outElement, Map<Integer, Score> results, Score total, Score uniqueTotal, ArrayList<Integer> countedItemIds) throws JSONException
    {
    	Score groupTotal = new Score();
		NodeList childNodes = inputElem.getChildNodes();
    	for (int childIndex=0; childIndex<childNodes.getLength(); childIndex++)
    	{
    		Node childNode = childNodes.item(childIndex);
    		if (childNode.getNodeType() == Node.ELEMENT_NODE && childNode.getNodeName().equals("group"))
    		{
    			Element childElem = (Element) childNode;
    			Element outGroupElem = outputDoc.createElement("group");
    			outGroupElem.setAttribute("title", childElem.getAttribute("title"));
    			outElement.appendChild(outGroupElem);
    			processGroup((Element)childNode, outputDoc, outGroupElem, results, groupTotal, uniqueTotal, countedItemIds);
    		}
    		if (childNode.getNodeType() == Node.ELEMENT_NODE && childNode.getNodeName().equals("item"))
    			processItem((Element)childNode, outputDoc, outElement, results, groupTotal, uniqueTotal, countedItemIds);
    	}
    	outElement.setAttribute("score", Integer.toString(groupTotal.score));
    	outElement.setAttribute("total", Integer.toString(groupTotal.total));
    	total.score += groupTotal.score;
    	total.total += groupTotal.total;
    }

    private void processItem(Element itemElem, Document outputDoc, Element groupElem, Map<Integer, Score> results, Score total, Score unique, ArrayList<Integer> countedItemIds) throws JSONException
    {
		int id = Integer.parseInt(itemElem.getAttribute("id"));
		Score score = results.get(id);
		if (score != null)
		{
			Element assignmentElem = outputDoc.createElement("assignment"); 
    		assignmentElem.setAttribute("id", 	 Integer.toString(id));
    		assignmentElem.setAttribute("title", itemElem.getAttribute("title"));
    		assignmentElem.setAttribute("score", Integer.toString(score.score));
    		assignmentElem.setAttribute("total", Integer.toString(score.total));
    		assignmentElem.setAttribute("made",  Boolean.toString(score.made));
    		groupElem.appendChild(assignmentElem);
    		total.score += score.score;
    		total.total += score.total;
    		if (!countedItemIds.contains(id))
    		{
    			unique.score += score.score;
    			unique.total += score.total;
    			countedItemIds.add(id);
    		}
		}
    }
    
    private void copyMetaElements(Document inputDoc, Document outputDoc, Element targetElem) {
		NodeList resultNodes = inputDoc.getElementsByTagName("result");
		Element metaElem = outputDoc.createElement("meta");
		if (resultNodes.getLength() > 0)
		{
			Element resultNode = (Element)resultNodes.item(0);
			NodeList metaNodes = resultNode.getElementsByTagName("meta");
			if (metaNodes.getLength() > 0)
			{
				Element metaNode = (Element)metaNodes.item(0);
				NodeList paramNodes = metaNode.getElementsByTagName("param");
				for (int i = 0; i < paramNodes.getLength(); i++)
				{
					Element paramNode = (Element) paramNodes.item(i);
					Element paramElem = outputDoc.createElement("param");
					paramElem.setAttribute("name", paramNode.getAttribute("name"));
					paramElem.setTextContent(paramNode.getTextContent());
					metaElem.appendChild(paramElem);
				}
			}
		}
		targetElem.appendChild(metaElem);
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
    
    public class Score
    {
    	public int score;
    	public int total;
    	public boolean made;
    }

}