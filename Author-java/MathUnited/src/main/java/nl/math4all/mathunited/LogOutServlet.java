package nl.math4all.mathunited;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

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

        // End the session
        HttpSession session = request.getSession();
        session.invalidate();

        String result = resultXML.replace("{#LOGINRESULT}","true").replace("{#LOGINMESSAGE}", "Logout successfull");

        // Write the result
        Writer w = response.getWriter();
        PrintWriter pw = new PrintWriter(w);
        pw.println(result);
    }
    
    @Override
    public void doPost ( HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
    }
    
}