package nl.math4all.mathunited.utils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import java.util.logging.Level;
import javax.servlet.http.Cookie;
import nl.math4all.mathunited.configuration.Configuration;
import nl.math4all.mathunited.configuration.Repository;

/**
 *
 * @author martijnslob
 */
public class Utils {
    public static Level LOGLEVEL = Level.FINE;
            
    public static Map<String, String> readParameters(HttpServletRequest request) {
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
        return parameterMap;
    }
    
    public static String readParameter(String name, boolean isRequired,HttpServletRequest request) throws Exception {
        Map<String, String[]> paramMap = request.getParameterMap();
        String[] pvalArr = paramMap.get(name);
        if(pvalArr==null || pvalArr.length==0) {
            if(isRequired) throw new Exception("Parameters "+name+" is required");
            return null;
        } else {
            return pvalArr[0];
        }
    }
 
    public static Repository getRepository(HttpServletRequest request) throws Exception {
        String repo = null;
        Cookie[] cookieArr = request.getCookies();
        if (cookieArr != null) {
            for (Cookie c : cookieArr) {
                if (c.getName().equals("REPO")) {
                    repo = c.getValue();
                }
            }
        }
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
    
}