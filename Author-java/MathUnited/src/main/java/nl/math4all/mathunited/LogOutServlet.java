package nl.math4all.mathunited;

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

public class LogOutServlet extends HttpServlet {
    private String resultXML = "<logout result=\"{#LOGINRESULT}\"><message>{#LOGINMESSAGE}</message></logout>";

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
            Cookie[] cookieArr = request.getCookies();
            if(cookieArr!=null) {
                for(Cookie c:cookieArr) {
                    if(c.getName().equals("USERID") || c.getName().equals("USERAGENT")) {
                        c.setMaxAge(0);  //remove cookie
                        response.addCookie(c);
                    }
                }
            }
            String result = resultXML.replace("{#LOGINRESULT}","true").replace("{#LOGINMESSAGE}", "Logout successfull");
            pw.println(result);
        } catch(Exception e) {
            e.printStackTrace();
            String result = resultXML.replace("{#LOGINRESULT}","false").replace("{#LOGINMESSAGE}", e.getMessage());
            pw.println(result);
        }
    
    }
    
    @Override
    public void doPost ( HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
    }
    
}