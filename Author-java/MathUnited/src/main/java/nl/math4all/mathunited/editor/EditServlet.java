package nl.math4all.mathunited.editor;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.Map;
import java.util.HashMap;
import javax.xml.transform.Source;
import java.util.Properties;
import nl.math4all.mathunited.XSLTbean;
import nl.math4all.mathunited.resolvers.ContentResolver;
import nl.math4all.mathunited.configuration.*;
import nl.math4all.mathunited.configuration.SubComponent;
import nl.math4all.mathunited.configuration.Component;
import nl.math4all.mathunited.utils.LockManager;
import nl.math4all.mathunited.utils.UserManager;
import nl.math4all.mathunited.utils.Utils;
import org.apache.commons.lang3.StringUtils;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class EditServlet extends HttpServlet {
    private static final int MAX_LOCK_DURATION_SECONDS = 60;
    
    private final static Logger LOGGER = Logger.getLogger(EditServlet.class.getName());
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
    public void doGet (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {

        try{
            //long tic = System.currentTimeMillis();
            //System.out.printf("#### Edit. Request received. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();

            Configuration config = Configuration.getInstance();
            //System.out.printf("#### Config obtained. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();

            UserSettings usettings = UserManager.isLoggedIn(request,response);
            //System.out.printf("#### UserSettings obtained. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();

            Repository repository = Utils.getRepository(request);
            //System.out.printf("#### Repository obtained. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();

            String comp = Utils.readParameter("comp", true, request);
            String subcomp = Utils.readParameter("subcomp", true, request);
            String variant = Utils.readParameter("variant", true, request);

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

            //System.out.printf("#### Processed parameters. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();

            
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

            if (repo == null) {
                throw new Exception("Er is geen archief geselecteerd.");
            }

            //System.out.printf("#### Repo selected. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();

            Repository baserepo = null;
            if (repository.baseRepo != null) {
                Map<String, Repository> repoMap = config.getRepos();
                baserepo = repoMap.get(repository.baseRepo);
            }

            //System.out.printf("#### BaseRepo obtained. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();


            //read components. To be moved to init()
            componentMap = repository.readComponentMap();
            //System.out.printf("#### Component map. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();

            Component component = componentMap.get(comp);
            if(component==null) {
                throw new Exception("Er bestaat geen component met id '"+comp+"'");
            }
            //System.out.printf("#### Component selected. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();

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
            //System.out.printf("#### SubComponent obtained. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();

            
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

            //System.out.printf("#### SubComponent selected. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();


            // supply path to subcomponent to xslt. Might be needed when resolving other xml-documents
            int ind = sub.file.lastIndexOf('/');
            String refbase;
            String basePath = repository.getPath();
            if (basePath.isEmpty()) {
                refbase = sub.file.substring(0, ind+1);
            } else {
                refbase = repository.getPath() + "/" + sub.file.substring(0, ind+1);
            }

            //System.out.printf("#### refbase. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();


            parameterMap.put("componentsURL", repository.componentsURL);
            parameterMap.put("threadsURL", repository.threadsURL);
            parameterMap.put("refbase", refbase);
            parameterMap.put("component", component.getXML());
            parameterMap.put("repo-path", repository.getPath());
            parameterMap.put("baserepo-path", baserepo == null ? "" : baserepo.getPath());
            //System.out.printf("#### refbase. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();

            component.addToParameterMap(parameterMap, subcomp);
            //System.out.printf("#### Parameter. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();

            String currentOwner = getLock(usettings.username, config.getContentRoot() + refbase);
            //System.out.printf("#### Get lock. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();

            if (currentOwner != null & !StringUtils.equals(currentOwner, usettings.username)) {
                if (currentOwner.startsWith("@@@")) {
                    parameterMap.put("lock_errormsg", currentOwner.substring(3));
                } else {
                    parameterMap.put("lock_owner", currentOwner);
                }
            }

            //System.out.printf("#### Parametermap & lock created. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();

            
            ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
            //System.out.printf("#### Byte stream created. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();

            ContentResolver resolver = new ContentResolver(repository, context);
            //System.out.printf("#### Resolver created. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();


            Source xmlSource = resolver.resolve(repository.getPath() + "/" + sub.file, "");
            //System.out.printf("#### xml source resolved. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();


            String errStr = processor.process(xmlSource, variant, parameterMap, resolver, byteStream);
            //System.out.printf("#### XML processed. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();
            
            
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

            //System.out.printf("#### Response written. %d ms%n", System.currentTimeMillis() - tic); tic = System.currentTimeMillis();

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

    /** Tries to get the lock on this subcomponent. 
     * @param username
     * @param refbase
     * @return null if lock is obtained. If the lock is owned by some other user, the
     *         username of this current owner is returned.
     * @throws Exception 
     */
    public String getLock(String username, String refbase) throws Exception {
        return LockManager.getInstance().getLock(username, refbase);
    }
    
    public boolean isMobile(String uaStr) {
        if(uaStr==null) return false;
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