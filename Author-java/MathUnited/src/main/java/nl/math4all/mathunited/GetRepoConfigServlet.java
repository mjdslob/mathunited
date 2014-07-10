package nl.math4all.mathunited;

import nl.math4all.mathunited.configuration.*;
import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.logging.Logger;
import java.util.Map;
import java.util.logging.Level;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class GetRepoConfigServlet extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(GetRepoConfigServlet.class.getName());

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        LOGGER.setLevel(Level.INFO);
    }

    @Override
    public void doGet ( HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/xml");
        Writer w = response.getWriter();
        PrintWriter pw = new PrintWriter(w);
        try {    
            String repostr = request.getParameter("repo");
            if(repostr==null) {
                throw new Exception("Missing argument 'repo'");
            }
            Configuration config = Configuration.getInstance();
            Map<String, Repository> repoMap = config.getRepos();
            Repository repository = repoMap.get(repostr);
            if(repository==null) {
                throw new Exception("Onbekende repository: "+repostr);
            }
            
            String result = 
                    "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
                  + "<repodata name=\""+repostr+"\">"
                  + "  <path>"+config.getContentRoot()+repository.getPath()+"</path>"
                  + "  <threadsURL>"+repository.threadsURL+"</threadsURL>"
                  + "  <componentsURL>"+repository.componentsURL+"</componentsURL>"
                  + "</repodata>";
            LOGGER.log(Level.FINE, result);
            pw.println(result);
        } catch(Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }
    
    @Override
    public void doPost ( HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
    }
    
}