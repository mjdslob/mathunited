package nl.math4all.mathunited.editor;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.Map;
import java.util.HashMap;
import java.util.Properties;
import nl.math4all.mathunited.configuration.*;
import nl.math4all.mathunited.configuration.Component;
import nl.math4all.mathunited.utils.UserManager;
import nl.math4all.mathunited.utils.Utils;

//get all content items (examples, exercises, etc) for a given component. Used for a selection widget 
//(see webapp/javascript/editor/ItemSelector.js)
public class GetComponentItemsServlet extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(GetComponentItemsServlet.class.getName());
    Map<String, Component> componentMap;
    ServletContext context;
    Properties prop = new Properties();
    
    @Override
    public void init(ServletConfig config) throws ServletException {
        try{
            super.init(config);
            context = getServletContext();
            LOGGER.setLevel(Level.INFO);
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
            UserSettings usettings = UserManager.isLoggedIn(request,response);
            Repository repository = Utils.getRepository(request);
            String comp = Utils.readParameter("comp", true, request);
            
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
            
            //read components. 
            componentMap = repository.readComponentMap();
            Component component = componentMap.get(comp);
            if(component==null) {
                throw new Exception("Er bestaat geen component met id '"+comp+"'");
            }

            int ind = component.compfile.lastIndexOf('/');
            String indexfname = config.getContentRoot()+repository.getPath()+"/"+component.compfile.substring(0, ind+1)+"index.xml";
            File findex = new File(indexfname);
            if(findex.exists()) {
                response.setContentType("application/xml");
                PrintWriter writer = response.getWriter();
                if(findex.exists()) {
                    BufferedReader br=null;
                    try {
                        br = new BufferedReader(new FileReader(findex));
                        StringBuilder sb = new StringBuilder();
                        String line = br.readLine();

                        while (line != null) {
                            writer.println(line);
                            line = br.readLine();
                        }
                    } catch(Exception e) {
                        LOGGER.severe("Error occurred: "+e.getMessage());
                    } finally {
                        if(br!=null) br.close();
                    }
                } 
            } else {
                throw new Exception("Cannot locate index file for component "+comp);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html");
            Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            pw.println("<html><head></head><body><h1>Fout opgetreden</h1><p>");
            pw.println(e.getMessage());
            pw.println("</p></body></html>");
        }
    }
    
    @Override
    public void doPost (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {
        //get the pdf from the session and return it
    }

}