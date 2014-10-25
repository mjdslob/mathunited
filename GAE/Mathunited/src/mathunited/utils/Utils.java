package mathunited.utils;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.spec.AlgorithmParameterSpec;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.KeyGenerator;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.commons.codec.binary.Base64;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import sun.misc.BASE64Encoder;
import mathunited.configuration.Repository;
import mathunited.model.Score;
import mathunited.model.ScoreGroup;
import mathunited.model.Student;
import mathunited.model.StudentList;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Text;
import com.google.appengine.labs.repackaged.org.json.JSONArray;
import com.google.appengine.labs.repackaged.org.json.JSONException;
import com.google.appengine.labs.repackaged.org.json.JSONObject;
import com.sun.org.apache.xml.internal.resolver.helpers.Debug;

public class Utils {
	
	public static String stackTraceToString(Exception e) {
		StringWriter sw = new StringWriter();
		PrintWriter pw = new PrintWriter(sw);
		e.printStackTrace(pw);
		return sw.toString(); 
	}

	
	public static String renderErrorHtml(Exception e) {
		String html =  
			"<div class='error'>" +
			"<h2>Fout</h2>" +
			e.getMessage() + "<br />";
		if (!(e instanceof UserException)) 
			html += stackTraceToString(e) + "<br />";
		html += "<p style='margin-bottom: 0'><a href='javascript:window.history.go(-1)'>&lt; Terug</a></p>";
		html += "</div>\n";
		return html;
	}
	
    /**
     * Returns scores of multiple students in the results parameter. The result is a map consisting of:
     * Map<"userid", 
     *     Map<assignmentid,
     *     		Score{score, total, made}
     *     >
     * >
     */
    public static void getEindExamenSiteResults(HashMap<Integer, Integer> eindExamenSiteItems, StudentList students, Map<String, Map<Integer, Score>> results) throws Exception {
    	for (Student student : students.items) {
    		Map<Integer, Score> userResults = new HashMap<Integer, Score>();
    		getEindExamenSiteResults(eindExamenSiteItems, student.userId, userResults);
    		results.put(student.userId, userResults);
		}
    }

    /**
     * Returns scores of a student in the results parameter
     */
    public static void getEindExamenSiteResults(HashMap<Integer, Integer> eindExamenSiteItems, String userid, Map<Integer, Score> results) throws Exception 
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
    		score.id = id;
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
    
    public static void processGroup(Element inputElem, Document outputDoc, Element outElement, Map<Integer, Score> results, Score total, Score uniqueTotal, ArrayList<Integer> countedItemIds) throws JSONException
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

    public static void processItem(Element itemElem, Document outputDoc, Element groupElem, Map<Integer, Score> results, Score total, Score unique, ArrayList<Integer> countedItemIds) throws JSONException
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
    
    public static JSONObject executeHttpPostResult(String url, JSONObject jsonObject) throws Exception
    {
    	return new JSONObject(executeHttpPostStringResult(url, jsonObject));
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


	public static Document getResultStrucureXml(Repository repository, String id) throws Exception
    {
	   DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

	   Key repoKey = KeyFactory.createKey("Repository", repository.id);
	   Key key = KeyFactory.createKey(repoKey, "XmlFile", id);
	   Entity entity = datastore.get(key);
	   Text textProp = (Text)entity.getProperty("text");
	   String xml = textProp.getValue();
       if (xml == null)
       		throw new Exception("Structuur xml met id " + id + " niet gevonden");
       
       DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
	   DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
	   InputSource is = new InputSource(new StringReader(xml));
	   return dBuilder.parse(is);
    }

	/**
	 * Returns the items that apply to the eindexamensite from the xml document and put them in a map consisting of:
	 * assignmentid, maximum score
	 */
	public static HashMap<Integer, Integer> getEindExamenSiteItems(Document inputDoc) {
		HashMap<Integer, Integer> result = new HashMap<Integer, Integer>();
		NodeList itemNodes = inputDoc.getElementsByTagName("item");
		for (int i=0; i < itemNodes.getLength(); i++)
		{
			Element itemElem = (Element)itemNodes.item(i);
			if (itemElem.getAttribute("source").equals("es"))
			{
				int id = Integer.parseInt(itemElem.getAttribute("id"));
				int total = Integer.parseInt(itemElem.getAttribute("total"));
				result.put(id, total);
			}
		}
		return result;
	}

	/** 
	 * Converts the result retrieved from the external site to a structured xml document of which the structure is 
	 * determined by the result-structure xml as published for the given thread 
	 * @throws ParserConfigurationException 
	 * @throws JSONException 
	 */
	public static Document transformResults(Document inputDoc, Map<Integer, Score> results) throws ParserConfigurationException, JSONException {
		DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
		DocumentBuilder docBuilder = docFactory.newDocumentBuilder();

		Document outputDoc = docBuilder.newDocument();
		Element rootElement = outputDoc.createElement("assignments");
		outputDoc.appendChild(rootElement);
		copyMetaElements(inputDoc, outputDoc, rootElement);
		
		Score uniqueTotal = new Score();
		Utils.processGroup(inputDoc.getDocumentElement(), outputDoc, rootElement, results, new Score(), uniqueTotal, new ArrayList<Integer>());
		rootElement.setAttribute("uniqueScore", Integer.toString(uniqueTotal.score));
		rootElement.setAttribute("uniqueTotal", Integer.toString(uniqueTotal.total));
		
		return outputDoc;
	}
	
    private static void copyMetaElements(Document inputDoc, Document outputDoc, Element targetElem) {
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
    
    /** 
	 * Converts the result retrieved from the external site to a structured object tree of which the structure is 
	 * determined by the result-structure xml as published for the given thread 
	 * @throws ParserConfigurationException 
	 * @throws JSONException 
	 */
	public static ScoreGroup transformResultsTree(Document inputDoc, Map<Integer, Score> results) throws ParserConfigurationException, JSONException {
		ScoreGroup output = new ScoreGroup();
		Score uniqueTotal = new Score();
		Utils.processGroupTree(inputDoc.getDocumentElement(), output, results, new Score(), uniqueTotal, new ArrayList<Integer>());
		output.score = uniqueTotal.score;
		output.total = uniqueTotal.total;
		
		return output;
	}
	
    public static void processGroupTree(Element inputElem, ScoreGroup output, Map<Integer, Score> results, Score total, Score uniqueTotal, ArrayList<Integer> countedItemIds) throws JSONException
    {
    	Score groupTotal = new Score();
		NodeList childNodes = inputElem.getChildNodes();
    	for (int childIndex=0; childIndex<childNodes.getLength(); childIndex++)
    	{
    		Node childNode = childNodes.item(childIndex);
    		if (childNode.getNodeType() == Node.ELEMENT_NODE && childNode.getNodeName().equals("group"))
    		{
    			Element childElem = (Element) childNode;
    			ScoreGroup subgroup = new ScoreGroup();
    			subgroup.title = childElem.getAttribute("title");
    			processGroupTree((Element)childNode, subgroup, results, groupTotal, uniqueTotal, countedItemIds);
    			output.groups.add(subgroup);
    		}
    		if (childNode.getNodeType() == Node.ELEMENT_NODE && childNode.getNodeName().equals("item"))
    			processItemTree((Element)childNode, output, results, groupTotal, uniqueTotal, countedItemIds);
    	}
    	output.score = groupTotal.score;
    	output.total = groupTotal.total;
    	total.score += groupTotal.score;
    	total.total += groupTotal.total;
    }
    
    public static void processItemTree(Element itemElem, ScoreGroup output, Map<Integer, Score> results, Score total, Score unique, ArrayList<Integer> countedItemIds) throws JSONException
    {
		int id = Integer.parseInt(itemElem.getAttribute("id"));
		Score score = results.get(id);
		if (score != null)
		{
			Score outscore = new Score();
			outscore.id = id;
			outscore.title = itemElem.getAttribute("title");
			outscore.score = score.score;
			outscore.total = score.total;
			outscore.made = score.made;
    		total.score += score.score;
    		total.total += score.total;
    		if (!countedItemIds.contains(id))
    		{
    			unique.score += score.score;
    			unique.total += score.total;
    			countedItemIds.add(id);
    		}
    		output.items.add(outscore);
		}
    }
    
    public static final String encDecKey = "Qzi8w2E+OHYRnPx7eLvnGw==";
    public static final String encDecAlgorithm = "AES";
    
    public static String generateKey() throws Exception {
    	KeyGenerator keyGen = KeyGenerator.getInstance(encDecAlgorithm);
    	keyGen.init(128); // for example
    	SecretKey secretKey = keyGen.generateKey();
    	return Base64.encodeBase64String(secretKey.getEncoded());
    }
    
    public static String encodeData(String stringToEncrypt) throws Exception {
    	byte[] encodedKey     = Base64.decodeBase64(encDecKey);
//        SecretKey originalKey = new SecretKeySpec(encodedKey, 0, 16, encDecAlgorithm);
//    	Cipher aesCipher = Cipher.getInstance(encDecAlgorithm); 
//    	aesCipher.init(Cipher.ENCRYPT_MODE,originalKey); 
//    	byte[] byteDataToEncrypt = stringToEncrypt.getBytes(); 
//    	byte[] byteCipherText = aesCipher.doFinal(byteDataToEncrypt); 
//    	return Base64.encodeBase64String(byteCipherText);
    	
    	SecretKeySpec originalKey = new SecretKeySpec(encodedKey, "AES");
    	Cipher cipher = Cipher.getInstance("AES/CBC/NoPadding");
    	int blockSize = cipher.getBlockSize();

    	byte[] inputBytes = stringToEncrypt.getBytes();
    	int byteLength = inputBytes.length;
    	if (byteLength % blockSize != 0) {
    	    byteLength = byteLength + (blockSize - (byteLength % blockSize));
    	}

    	byte[] paddedBytes = new byte[byteLength];

    	System.arraycopy(inputBytes, 0, paddedBytes, 0, inputBytes.length);

    	byte[] iv  = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
    	AlgorithmParameterSpec ivSpec = new IvParameterSpec(iv);
    	
    	cipher.init(Cipher.ENCRYPT_MODE, originalKey, ivSpec);
    	byte[] results = cipher.doFinal(paddedBytes);    
    	return Base64.encodeBase64String(results);
    }
    
    public static String decodeData(String stringToDecrypt) throws Exception {
    	byte[] encodedKey     = Base64.decodeBase64(encDecKey);
        SecretKey originalKey = new SecretKeySpec(encodedKey, 0, 16, "AES");
    	Cipher aesCipher = Cipher.getInstance("AES/CBC/NoPadding"); 

    	byte[] iv  = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
    	AlgorithmParameterSpec ivSpec = new IvParameterSpec(iv);
        
    	aesCipher.init(Cipher.DECRYPT_MODE, originalKey, ivSpec); 
        byte[] byteCipherText = Base64.decodeBase64(stringToDecrypt);
        byte[] byteDecryptedText = aesCipher.doFinal(byteCipherText); 
        return new String(byteDecryptedText);
    }
    
    public static String userIdFromLoginToken(String logintoken) throws Exception {
    	if (logintoken == null || logintoken.length() == 0) return "";
       	String decodedToken = Utils.decodeData(logintoken);
       	int idx = decodedToken.indexOf('|');
       	return decodedToken.substring(0, idx);
    }
    
    public static String userRoleFromLoginToken(String logintoken) throws Exception {
    	if (logintoken == null || logintoken.length() == 0) return "";
       	String decodedToken = Utils.decodeData(logintoken);
       	int idx1 = decodedToken.indexOf('|');
       	int idx2 = decodedToken.lastIndexOf('|');
       	return decodedToken.substring(idx1 + 1, idx2);
    }

    public static String userSchoolFromLoginToken(String logintoken) throws Exception {
    	if (logintoken == null || logintoken.length() == 0) return "";
       	String decodedToken = Utils.decodeData(logintoken);
       	int idx = decodedToken.lastIndexOf('|');
       	return decodedToken.substring(idx + 1).trim();
    }
}
