package nl.math4all.mathunited;

import nl.math4all.mathunited.utils.UserManager;
import nl.math4all.mathunited.configuration.*;
import nl.math4all.mathunited.exceptions.LoginException;
import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.Map;
import java.util.HashMap;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class LoginStateServlet extends HttpServlet {
    private String resultXML = "<state result=\"true\" logged-in=\"{#LOGINRESULT}\" name=\"{#UNAME}\" repo=\"{#REPOID}\"><repos>{#REPOSET}</repos></state>";
    private String resultXMLError = "<state result=\"false\" logged-in=\"false\" name=\"\"><message>{#MESSAGE}</message></state>";

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
    }

    @Override
    public void doGet ( HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/xml");
        Writer w = response.getWriter();
        PrintWriter pw = new PrintWriter(w);
        try {    
            //check if user is logged in
            String userName = null;
            Configuration config = Configuration.getInstance();
            String repoId = "";
            Cookie[] cookieArr = request.getCookies();
            if(cookieArr != null) {
                for(Cookie c:cookieArr) {
                    String name = c.getName();
                    if(name.equals("REPO")) {
                        repoId = c.getValue();
                    }
                    if(name.equals("USERID")) {
                        userName = c.getValue();
                    }
                }
            }

            UserSettings usettings = UserManager.isLoggedIn(request, response);

            String repoStr = "";
            //get repos that user can edit
            for(Map.Entry<String, Repository> entry : config.getRepos().entrySet()) {
                if(hasRightToEdit(usettings, entry.getValue())) {
                    repoStr = repoStr + "<repo name=\""+entry.getKey()+"\"/>";
                }
            }
            pw.println(resultXML.replace("{#LOGINRESULT}","true").replace("{#UNAME}", userName).replace("{#REPOSET}",repoStr)
                    .replace("{#REPOID}",repoId));
        } catch(LoginException e) {
            String result = resultXMLError.replace("{#MESSAGE}", e.getMessage());
            System.out.println(result);
            pw.println(result);
        } catch(Exception e) {
            throw new ServletException(e);
        } 
    
    }
    
    private boolean hasRightToEdit(UserSettings usettings, Repository repository) {
        boolean access = false;
        for(String role : usettings.roles) {
            if(role.equals(repository.edit_permission)) {
                access = true;
                break;
            }
        }
        return access;
    }
    @Override
    public void doPost ( HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
    }
    

}