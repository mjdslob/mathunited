package nl.math4all.mathunited;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import nl.math4all.mathunited.configuration.*;
import nl.math4all.mathunited.utils.UserManager;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class SetRepoServlet extends HttpServlet {
    private String resultXML = "<setrepo result=\"{#POSTRESULT}\"><message>{#MESSAGE}</message></setrepo>";


    @Override
    public void doGet ( HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/xml");
        Writer w = response.getWriter();
        PrintWriter pw = new PrintWriter(w);
        try{
            //check if user is logged in
            Configuration config = Configuration.getInstance();
            UserSettings usettings = UserManager.isLoggedIn(request, response);
            
            String repo = request.getParameter("repo");
            if(repo==null) {
                throw new Exception("Het verplichte argument 'repo' ontbreekt.");
            }

            Repository repository = config.getRepos().get(repo);
            if(repository==null) {
                throw new Exception(repo+" is een ongeldige repository");
            }
            Cookie cookie = new Cookie("REPO", repo);
            cookie.setMaxAge(24*60*60);
            response.addCookie(cookie);
            
            String result = resultXML.replace("{#POSTRESULT}","true").replace("{#MESSAGE}", "success");
            pw.println(result);
        }
        catch (Exception e) {
            e.printStackTrace();
            String result = resultXML.replace("{#POSTRESULT}","false").replace("{#MESSAGE}", e.getMessage());
            pw.println(result);
        }
        
    }
    
 
    
    
}