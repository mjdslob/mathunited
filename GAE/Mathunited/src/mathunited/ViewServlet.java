package mathunited;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.Source;

import mathunited.configuration.Component;
import mathunited.configuration.Configuration;
import mathunited.configuration.Repository;
import mathunited.configuration.SubComponent;

public class ViewServlet extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(XSLTbean.class.getName());
	static {LOGGER.setLevel(Level.INFO);}
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
    public void doGet (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {

        try{
        	Configuration config = Configuration.getInstance(context);
            XSLTbean processor = new XSLTbean(context, config.getVariants());

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
            String comp = parameterMap.get("comp");
            String subcomp = parameterMap.get("subcomp");
            if(comp==null) {
                throw new Exception("Het verplichte argument 'comp' ontbreekt.");
            }
            
            if(subcomp==null) {
                throw new Exception("Het verplichte argument 'subcomp' ontbreekt.");
            }
            
            String repo = parameterMap.get("repo");
            String variant = parameterMap.get("variant");
            if(repo==null) {
                //try to get repo from variant (hack to prevent problems with old urls...)
                if(variant!=null){
                    if(variant.equals("basis_wm") || variant.equals("wm_view")) repo = "wm";
                    else if(variant.equals("basis") || variant.equals("m4a_view")) repo= "m4a";
                    else if(variant.equals("basis_studiovo") || variant.equals("studiovo_view")) repo="studiovo";
                    LOGGER.info("Setting repo from variant: "+repo);
                }
            }
           	if(repo==null)
           		throw new Exception("Het verplichte argument 'repo' ontbreekt: "+repo);
           	
            Repository repository = config.getRepos().get(repo);
            if(repository==null) {
                throw new Exception("Onbekende repository: "+repo);
            }
            //get default variant for this repo or get it from the url
            if(variant==null) {
                variant = repository.defaultVariant;
                if(variant==null || variant.isEmpty()) {
                    throw new Exception("Geef aan welke layout gebruikt dient te worden");
                }
            }
            
            Component component = repository.getComponent(comp);
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
            
            // find subcomponent
            SubComponent sub=null;
            int subcomp_index = 0;
            for(subcomp_index=0; subcomp_index<component.subComponentList.size(); subcomp_index++ ){
                sub = component.subComponentList.get(subcomp_index);
                if(sub.id.equals(subcomp)) {
                    break;
                }
            }
            if(sub==null) {
                throw new Exception("Er bestaat geen subcomponent met id '"+subcomp+"'");
            }
            
            int ind = sub.file.lastIndexOf('/');
            parameterMap.put("refbase", repository.path+"/"+sub.file.substring(0, ind+1));
            parameterMap.put("component", component.getXML());
            component.addToParameterMap(parameterMap, subcomp);
            parameterMap.put("repo", repo);
            parameterMap.put("requesturl", request.getRequestURL().toString() + "?" + request.getQueryString());
            ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
            ContentResolver resolver = new ContentResolver(repo, sub.file, context);
            Source xmlSource = resolver.resolve(sub.file, "root");
            
            processor.process(xmlSource, variant, parameterMap, resolver, byteStream);
            response.setContentType("text/html");
            
            byte[] result = byteStream.toByteArray();
            response.setContentLength(result.length);
            ServletOutputStream os = response.getOutputStream();
            os.write(result);
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

}