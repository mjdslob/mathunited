package nl.math4all.mathunited;

import nl.math4all.mathunited.configuration.*;
import nl.math4all.mathunited.exceptions.LoginException;
import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.Map;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class LoginRegisterServlet extends HttpServlet {
    private String resultXML = "<register result=\"{#LOGINRESULT}\"><message>{#LOGINMESSAGE}</message></register>";

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
        System.out.println("LoginRegisterServlet called");
        response.setContentType("application/xml");
        Writer w = response.getWriter();
        PrintWriter pw = new PrintWriter(w);
        try {    
            String name = request.getParameter("name");
            String password = request.getParameter("password");
            if(name==null) {
                throw new LoginException("Please set username");
            }
            if(password==null) {
                throw new LoginException("Please set password");
            }

            Users users = Users.getInstance();
            Map<String, UserSettings> userMap = users.getUsers();
            UserSettings usettings = userMap.get(name);
            if(usettings!=null) {
                throw new LoginException("Username already exists");
            }

            UserSettings newUser = new UserSettings();
            newUser.salt = Math.round(1e6*Math.random());
            newUser.password = MD5(password+(""+newUser.salt));
            newUser.roles = new java.util.ArrayList<String>();
            userMap.put(name, newUser);
            users.save();
            
            pw.println(resultXML.replace("{#LOGINRESULT}","true").replace("{#LOGINMESSAGE}", "Registering successfull"));
            
        } catch(LoginException e) {
            String result = resultXML.replace("{#LOGINRESULT}","false").replace("{#LOGINMESSAGE}", e.getMessage());
            System.out.println(result);
            pw.println(result);
        } catch(Exception e) {
            throw new ServletException(e);
        } 
    
    }
    
    public String MD5(String md5) {
    try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
            byte[] array = md.digest(md5.getBytes());
            StringBuffer sb = new StringBuffer();
            for (int i = 0; i < array.length; ++i) {
            sb.append(Integer.toHexString((array[i] & 0xFF) | 0x100).substring(1,3));
        }
            return sb.toString();
        } catch (java.security.NoSuchAlgorithmException e) {
        }
        return null;
    }
    

}