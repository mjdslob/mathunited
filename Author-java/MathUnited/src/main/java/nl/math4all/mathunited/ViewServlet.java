package nl.math4all.mathunited;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.Map;
import java.util.HashMap;
import javax.xml.transform.Source;
import java.util.Properties;
import nl.math4all.mathunited.resolvers.ContentResolver;
import nl.math4all.mathunited.configuration.*;
import nl.math4all.mathunited.configuration.SubComponent;
import nl.math4all.mathunited.configuration.Component;
import nl.math4all.mathunited.utils.SvnUtils;
import nl.math4all.mathunited.utils.Utils;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class ViewServlet extends HttpServlet {
    static final byte[] EOL = {(byte)'\r', (byte)'\n' };
    private final static Logger LOGGER = Logger.getLogger(ViewServlet.class.getName());
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
            Configuration config = Configuration.getInstance();
            
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

            String comp = Utils.readParameter("comp", true, request);
            String subcomp = Utils.readParameter("subcomp", true, request);

            // find out which repository to use
            // try to get repo from cookie
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
            String variant = parameterMap.get("variant");
            if (repo == null) {
                //try to get repo from variant (hack to prevent problems with old urls...)
                if (variant != null) {
                    if (variant.equals("basis_wm") || variant.equals("wm_view")) {
                        repo = "wm";
                    } else if (variant.equals("basis") || variant.equals("m4a_view")) {
                        repo = "m4a";
                    } else if (variant.equals("basis_studiovo") || variant.equals("studiovo_view")) {
                        repo = "studiovo";
                    }
                    System.out.println("Setting repo from variant: " + repo);
                }
            	if(repo==null)
                    throw new Exception("Het verplichte argument 'repo' ontbreekt: "+repo);
            }

            Map<String, Repository> repoMap = config.getRepos();
            Repository repository = repoMap.get(repo);
            if(repository==null) {
                throw new Exception("Onbekende repository: "+repo);
            }

            Repository baserepo = null;
            if(repository.baseRepo!=null) {
                baserepo = repoMap.get(repository.baseRepo);
            }
            //get default variant for this repo or get it from the url
            if(variant==null) {
                variant = repository.defaultVariant;
                if(variant==null || variant.isEmpty()) {
                    throw new Exception("Geef aan welke layout gebruikt dient te worden");
                }
            }
            
            //read components. To be moved to init()
            componentMap = repository.readComponentMap();
            Component component = componentMap.get(comp);
            if(component==null) {
                throw new Exception("Er bestaat geen component met id '"+comp+"'");
            }
            
            
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
            
            // supply path to subcomponent to xslt. Might be needed when resolving other xml-documents
            int ind = sub.file.lastIndexOf('/');
            String repoPath = repository.getPath();
            if (repoPath.length() > 0) {
                repoPath=repoPath+"/";
            }

            String refbase = repoPath + sub.file.substring(0, ind+1);
            if (SvnUtils.hasSubversion()) {
                // Update to latest version
                File contentRoot = new File(Configuration.getInstance().getContentRoot());
                File refpath = new File(contentRoot, refbase);
                SvnUtils.svn(true, "update", refpath.toString());
                File imagedir = new File(refpath, "../images");
                SvnUtils.svn(false, "update", imagedir.toString());
            }
            parameterMap.put("refbase", refbase);
            parameterMap.put("component", component.getXML());
            component.addToParameterMap(parameterMap, subcomp);
            parameterMap.put("repo-path", repository.getPath());
            parameterMap.put("baserepo-path", baserepo==null?"":baserepo.getPath());
            parameterMap.put("requesturl", request.getRequestURL().toString() + "?" + request.getQueryString());
            ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
            ContentResolver resolver = new ContentResolver(repository, context);
            
            Source xmlSource = resolver.resolve(repository.getPath()+"/"+sub.file, "");
            String errStr = processor.process(xmlSource, variant, parameterMap, resolver, byteStream);

            response.setContentType("text/html");
            if(errStr.length()>0){
                PrintWriter writer = response.getWriter();
                String resultStr = "<html><head></head><body>" + errStr + "</body></html>";
                writer.println(resultStr);
            } else {
                byte[] result = byteStream.toByteArray();
                response.setContentLength(result.length);
                ServletOutputStream os = response.getOutputStream();
                os.write(result);
            }

        }
        catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html");
            Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            pw.println("<html><head></head><body><h1>Fout opgetreden</h1><p>");
            pw.printf("<p>Exception type: <tt>%s</tt></p>\n", e.getClass().getName());
            pw.printf("<p>Exception message: <i>%s</i</p>\n", e.getMessage());
            pw.println("</p></body></html>");
//            throw new ServletException(e);
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