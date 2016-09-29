package nl.math4all.mathunited.utils;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import java.util.logging.Level;
import javax.servlet.http.Cookie;
import nl.math4all.mathunited.configuration.Configuration;
import nl.math4all.mathunited.configuration.Repository;
import org.apache.commons.io.FilenameUtils;

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

}
