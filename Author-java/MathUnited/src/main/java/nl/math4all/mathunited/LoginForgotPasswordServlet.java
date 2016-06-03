package nl.math4all.mathunited;

import nl.math4all.mathunited.configuration.*;
import nl.math4all.mathunited.exceptions.LoginException;
import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import nl.math4all.mathunited.utils.UserManager;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class LoginForgotPasswordServlet extends HttpServlet {
    private String resultXML = "<forgot result=\"{#LOGINRESULT}\"><message>{#LOGINMESSAGE}</message></forgot>";

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
    }

    @Override
    public void doGet ( HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    
    }
    
    @Override
    public void doPost ( HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/xml");
        Writer w = response.getWriter();
        PrintWriter pw = new PrintWriter(w);
        try {    
            String name = request.getParameter("name");
            if(name==null) {
                throw new LoginException("Please set username");
            }
            name = name.trim();

            //UserSettings usettings = UserManager.resetPassword(name);
            pw.println(resultXML.replace("{#LOGINRESULT}","true")
                        .replace("{#LOGINMESSAGE}","Neemt u aub contact op met de administratie."));

            /*pw.println(resultXML.replace("{#LOGINRESULT}","true")
                        .replace("{#LOGINMESSAGE}", 
                                 "Nieuw wachtwoord is verstuurd naar " + usettings.mail));*/
              
        } catch(LoginException e) {
            String result = resultXML.replace("{#LOGINRESULT}","false").replace("{#LOGINMESSAGE}", e.getMessage());
            System.out.println(result);
            pw.println(result);
        } catch(Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    
    }
    
}