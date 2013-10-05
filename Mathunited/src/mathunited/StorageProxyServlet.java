package mathunited;

import java.io.*;
import java.net.*;

import javax.servlet.*;
import javax.servlet.http.*;

import java.util.Map;
import java.util.HashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

public class StorageProxyServlet extends HttpServlet {
    ServletContext context;
    private final static Logger LOGGER = Logger.getLogger(XSLTbean.class.getName());
    
    @Override
    public void doGet (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {

        try{
            //read request parameters
            Map<String, String[]> paramMap = request.getParameterMap();
            String[] strarr = paramMap.get("cmd");
            if(strarr==null || strarr.length==0) {
                throw new Exception("No command supplied");
            }

            String url = "http://m4a-storage.appspot.com/"+strarr[0];
            boolean isFirst = true;
            for(Map.Entry<String, String[]> entry : paramMap.entrySet()) {
                String pname = entry.getKey();
                String[] pvalArr = entry.getValue();
                if(!pname.equals("cmd") && pvalArr!=null && pvalArr.length>0) {
	                if(isFirst) {
    	               url = url + "?" + pname + "=" + pvalArr[0];
    	               isFirst = false;
	                } else {
	                   url = url + "&" + pname + "=" + pvalArr[0];
	                }
                } 
            }
		
			LOGGER.info("Forward to url: "+url);
			
		    URL website = new URL(url);
	        URLConnection connection = website.openConnection();
	        BufferedReader in = new BufferedReader(
	                                new InputStreamReader(
                                    connection.getInputStream()));
	
	        StringBuilder str = new StringBuilder();
	        String inputLine;
	        while ((inputLine = in.readLine()) != null) 
	            str.append(inputLine);
	        in.close();
	
            response.setContentType("application/xml");
            Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            pw.println(str.toString());
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
    
    @Override
    public void doPost (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {
        //get the pdf from the session and return it
    }

}