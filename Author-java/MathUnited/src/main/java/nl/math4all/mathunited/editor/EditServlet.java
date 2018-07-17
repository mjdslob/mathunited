package nl.math4all.mathunited.editor;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.Map;
import javax.xml.transform.Source;
import java.util.Properties;
import nl.math4all.mathunited.XSLTbean;
import nl.math4all.mathunited.resolvers.ContentResolver;
import nl.math4all.mathunited.configuration.*;
import nl.math4all.mathunited.configuration.SubComponent;
import nl.math4all.mathunited.configuration.Component;
import nl.math4all.mathunited.utils.*;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.SystemUtils;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class EditServlet extends HttpServlet {
    private static final int MAX_LOCK_DURATION_SECONDS = 60;
    
    private final static Logger LOGGER = Logger.getLogger(EditServlet.class.getName());
    XSLTbean processor;
    Map<String, Component> componentMap;

    Properties prop = new Properties();
    
    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        LOGGER.setLevel(Level.INFO);
        processor = new XSLTbean(getServletContext());
    }

    @Override
    public void doGet (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {

        //response.addHeader("Access-Control-Allow-Origin", "*");

        try {
            long tic = System.currentTimeMillis();

            Configuration config = Configuration.getInstance();
            UserSettings usettings = UserManager.isLoggedIn(request);
            Repository repository = Utils.getRepository(request);

            String comp = Utils.readParameter("comp", true, request);
            String subcomp = Utils.readParameter("subcomp", true, request);
            String variant = Utils.readParameter("variant", true, request);

            //read request parameters
            Map<String, String> parameterMap = Utils.readParameters(request);

            if (isMobile(request.getHeader("user-agent"))) {
                parameterMap.put("is_mobile", "true");
            } else {
                parameterMap.put("is_mobile", "false");
            }

            //find out which repository to use
            //try to get repo from cookie
            String repo = parameterMap.get("repo");
            String cookieRepo = Utils.getRepoID(request);
            if (cookieRepo != null) {
                repo = cookieRepo;
                parameterMap.put("repo", repo);
            }
            if (repo == null) {
                throw new Exception("Er is geen archief geselecteerd.");
            }


            Repository baserepo = null;
            if (repository.baseRepo != null) {
                Map<String, Repository> repoMap = config.getRepos();
                baserepo = repoMap.get(repository.baseRepo);
            }

            //read components. To be moved to init()
            componentMap = repository.readComponentMap();

            Component component = componentMap.get(comp);
            if (component == null) {
                throw new Exception("Er bestaat geen component met id '" + comp + "'");
            }

            //if subcomp is not an integer, it will be interpreted as the index of the subcomponent.
            //note: this implies that an id of a subcomponent can not be an integer!
            try {
                int subcomp_index = Integer.parseInt(subcomp);
                if (subcomp_index > 0 && subcomp_index <= component.subComponentList.size()) {
                    SubComponent sub = component.subComponentList.get(subcomp_index - 1);
                    subcomp = sub.id;
                }
            } catch (NumberFormatException exc) {

            }


            // find subcomponent, previous and following
            SubComponent sub = null, nextSub = null, prevSub = null;
            int subcomp_index = 0;
            for (subcomp_index = 0; subcomp_index < component.subComponentList.size(); subcomp_index++) {
                sub = component.subComponentList.get(subcomp_index);
                if (sub.id.equals(subcomp)) {
                    if (subcomp_index > 0) prevSub = component.subComponentList.get(subcomp_index - 1);
                    if (subcomp_index < component.subComponentList.size() - 1)
                        nextSub = component.subComponentList.get(subcomp_index + 1);
                    break;
                }
            }
            if (sub == null) {
                throw new Exception("Er bestaat geen subcomponent met id '" + subcomp + "'");
            }

            // supply path to subcomponent to xslt. Might be needed when resolving other xml-documents
            int ind = sub.file.lastIndexOf('/');
            String refbase;
            String basePath = repository.getPath();
            if (basePath.isEmpty()) {
                refbase = sub.file.substring(0, ind + 1);
            } else {
                refbase = repository.getPath() + "/" + sub.file.substring(0, ind + 1);
            }

            parameterMap.put("componentsURL", repository.componentsURL);
            parameterMap.put("threadsURL", repository.threadsURL);
            parameterMap.put("refbase", refbase);
            parameterMap.put("component", component.getXML());
            parameterMap.put("repo-path", repository.getPath());
            parameterMap.put("baserepo-path", baserepo == null ? "" : baserepo.getPath());


            component.addToParameterMap(parameterMap, subcomp);

            long toc = System.currentTimeMillis();
            System.out.println("[TIMING] @@@ edit: preamble took " + (toc - tic) + " ms.");

            tic = toc;
            Lock lock = LockManager.getInstance(getServletContext())
                    .getLock(usettings.username, config.getContentRoot() + refbase);
            toc = System.currentTimeMillis();
            System.out.println("[TIMING] @@@ edit: user locking took " + (toc - tic) + " ms.");

            tic = toc;

            // Check lock was indeed returned
            if (lock == null) {
                // If not, that is a server error. Communicate to user. Details are in server log.
                parameterMap.put("lock_errormsg", "locking error on server");
            } else if(config.getSvnRepoRoot()!=null){
                if (!StringUtils.equals(lock.getUsername(), usettings.username)) {
                    // Other user is locking. Notify and communicate which user,
                    parameterMap.put("lock_owner", lock.getUsername());
                } else {
                    // Update from repo with script
                    ScriptRunner runner = new ScriptRunner(new PrintWriter(System.out));
                    try {
                        runner.runScript("svn-update-paragraph", true, lock.getRefbase(), usettings.username);
                        lock.updated();
                    } catch (SvnException e) {
                        LOGGER.warning("svn-update-paragraph on " + lock.getRefbase() + " for user " + usettings.username + " failed.");
                        lock.updateFailed();
                        throw e;
                    }
                }
                // Expose lock status information to XSLT
                parameterMap.put("info_session_start", ShowLocksServlet.stringForTimestamp(lock.getSessionStart()));
                parameterMap.put("info_last_update", ShowLocksServlet.stringForTimestamp(lock.getLastUpdate()));
                parameterMap.put("info_last_commit", ShowLocksServlet.stringForTimestamp(lock.getLastCommit()));
            }

            ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
            ContentResolver resolver = new ContentResolver(repository, getServletContext());
            Source xmlSource = resolver.resolve(repository.getPath() + "/" + sub.file, "");

            toc = System.currentTimeMillis();
            System.out.println("[TIMING] @@@ edit: setting up before xml processing took " + (toc - tic) + " ms.");

            tic = toc;
            String errStr = processor.process(xmlSource, variant, parameterMap, resolver, byteStream);
            toc = System.currentTimeMillis();
            System.out.println("[TIMING] @@@ edit: xml processing took " + (toc - tic) + " ms.");

            tic = toc;

            response.setContentType("text/html");

            if(errStr.length() > 0){
                PrintWriter writer = response.getWriter();
                String resultStr = "<html><head></head><body>"+errStr+"</body></html>";
                writer.println(resultStr);
            } else {
                byte[] result = byteStream.toByteArray();
                response.setContentLength(result.length);
                ServletOutputStream os = response.getOutputStream();
                os.write(result);
            }

            toc = System.currentTimeMillis();
            System.out.println("[TIMING] @@@ edit: writing result " + (toc - tic) + " ms.");

        }
        catch (Exception e) {
            System.out.println(Utils.echoContext(request, "ERROR"));
            Utils.writeError(response, e);
        }

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