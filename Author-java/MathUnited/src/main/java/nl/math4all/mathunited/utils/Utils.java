package nl.math4all.mathunited.utils;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.Servlet;
import javax.servlet.ServletOutputStream;
import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;

import nl.math4all.mathunited.configuration.Configuration;
import nl.math4all.mathunited.configuration.Repository;
import nl.math4all.mathunited.configuration.UserSettings;
import nl.math4all.mathunited.exceptions.MathUnitedException;
import org.apache.commons.io.FilenameUtils;

/**
 *
 * @author martijnslob
 */
public class Utils {
    public static Level LOGLEVEL = Level.FINE;
    private final static Logger LOGGER = Logger.getLogger(Utils.class.getName());

    private static String serializeToJson(String str) { return "\""+str+"\""; }
    private static String serializeToJson(Map<String, Object> params) {
        StringBuilder result = new StringBuilder("{");
        boolean first = true;
        
        for (Map.Entry<String, Object> entry : params.entrySet()) {
            if(first) {
                first = false;
            } else {
                result.append(",");
            }
            result.append("\"")
                    .append(entry.getKey())
                    .append("\":");
            
            Object val = entry.getValue();
            if(val instanceof String) {
                result.append(serializeToJson((String)val));
            } else if(val instanceof Map) {
                result.append( serializeToJson((Map<String, Object>) val));
            } else {
                throw new Error("Unexpected content: "+val);
            }
        }
 
        result.append("}");
        System.out.println("MSLO-DEBUG: request = "+result.toString());
        return result.toString();
    }
    private static String getParamsString(Map<String, Object> params) throws UnsupportedEncodingException{
        String result = serializeToJson(params);
        System.out.println("MSLO-DEBUG: request = "+result);
        return result;
    }

    public static String httpPost(String dest, Map<String, Object> parameters) throws Exception {
        try{
            URL url = new URL(dest);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("POST");
            con.setRequestProperty("Content-Type", "application/json");
            con.setDoOutput(true);
            DataOutputStream out = new DataOutputStream(con.getOutputStream());
            out.writeBytes(getParamsString(parameters));
            out.flush();
            out.close();

            int status = con.getResponseCode();
            BufferedReader in = new BufferedReader(
                    new InputStreamReader(con.getInputStream()));
            String inputLine;
            StringBuffer response = new StringBuffer();

            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();
            return response.toString();
        } catch(Exception e) {
            throw e;
        }
    }
    public static Map<String, String> readParameters(HttpServletRequest request) {
        //read request parameters
        Map<String, String[]> paramMap = request.getParameterMap();
        Map<String, String> parameterMap = new HashMap<String, String>();
        for(Map.Entry<String, String[]> entry : paramMap.entrySet()) {
            String pname = entry.getKey();
            String[] pvalArr = entry.getValue();
            if (pvalArr != null && pvalArr.length > 0) {
               parameterMap.put(pname, pvalArr[0]);
            }
        }
        return parameterMap;
    }
    
    public static String readParameter(String name, boolean isRequired, HttpServletRequest request) throws Exception {
        Map<String, String[]> paramMap = request.getParameterMap();
        String[] pvalArr = paramMap.get(name);
        if(pvalArr == null || pvalArr.length == 0) {
            if (isRequired) {
                throw new Exception("Parameters " + name + " is required");
            }
            return null;
        } else {
            return pvalArr[0];
        }
    }

    public static String getRepoID(HttpServletRequest request) {
        String repoID = null;
        Cookie[] cookieArr = request.getCookies();
        if (cookieArr != null) {
            for (Cookie c : cookieArr) {
                if (c.getName().equals("REPO")) {
                    repoID = c.getValue();
                    break;
                }
            }
        }
        return repoID;
    }
 
    public static Repository getRepository(HttpServletRequest request) throws Exception {
        String repo = getRepoID(request);
        if (repo == null) {
            throw new Exception("Er is geen archief geselecteerd.");
        }
        Configuration config = Configuration.getInstance();
        Map<String, Repository> repoMap = config.getRepos();
        Repository repository = repoMap.get(repo);
        if(repository==null) {
            throw new Exception("Onbekende repository: "+repo);
        }
        return repository;
    }

    public static boolean isSubDirectory(File base, File child)
            throws IOException {
        base = base.getCanonicalFile();
        child = child.getCanonicalFile();

        File parentFile = child;
        while (parentFile != null) {
            if (base.equals(parentFile)) {
                return true;
            }
            parentFile = parentFile.getParentFile();
        }

        return false;
    }

    public static String pathJoin(String... parts) {
        String joined = new String();
        for (String part : parts) {
            joined = FilenameUtils.concat(joined, part);
        }
        return joined;
    }

    public static void writeError(HttpServletResponse response, Exception e) {
        e.printStackTrace();
        response.setContentType("text/html");
        try {
            Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            pw.println("<html><head></head><body><h1>Fout opgetreden</h1><p>");
            pw.println(e.getMessage());
            pw.println("</p></body></html>");
        } catch (IOException e2) {
            LOGGER.warning("Could not write error to client: " + e.getMessage());
        }
    }

    public static String echoContext(ServletRequest servletRequest, String prefix) {
        // Get the name of the servlet request if possible
        StringBuilder builder = new StringBuilder();
        builder.append("[" + prefix + "] Servlet ");

        if (servletRequest instanceof HttpServletRequest) {
            HttpServletRequest request = (HttpServletRequest) servletRequest;
            builder.append(request.getRequestURI());

            // See if component info is available
            try {
                for (String key : new String[] {"comp", "subcomp", "variant"}) {
                    String val = Utils.readParameter(key, true, request);
                    builder.append(' ');
                    builder.append(key);
                    builder.append('=');
                    builder.append(val);
                }
            } catch (Exception e){
                // ignore...
            }

            // See if user info is available
            try {
                UserSettings usettings = UserManager.isLoggedIn(request);
                builder.append(" for user=");
                builder.append(usettings.username);
            } catch (MathUnitedException e) {
                // ignore...
            }
        }

        return builder.toString();
    }
}
