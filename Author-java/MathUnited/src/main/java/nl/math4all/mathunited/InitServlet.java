package nl.math4all.mathunited;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.Map;
import java.util.HashMap;
import nl.math4all.mathunited.resolvers.ContentResolver;
import nl.math4all.mathunited.configuration.*;


//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class InitServlet extends HttpServlet {

    @Override
    public void init(ServletConfig config) throws ServletException {
         super.init(config);
    }


    @Override
    public void doGet (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {

        try{
            XSLTbean.clearTemplates();
            Configuration.clear();
            Users.clear();
            
            response.setContentType("text/html");
            Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            pw.println("<html><head></head><body><h1>De webtransformatie is opnieuw geinitialiseerd</h1><p>");
            pw.println("</p></body></html>");
        }
        catch (Exception e) {
            e.printStackTrace(response.getWriter());
            response.setContentType("text/html");
            Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            pw.println("<html><head></head><body><h1>Fout opgetreden</h1><p>");
            pw.println(e.getMessage());
            pw.println("</p></body></html>");
//            throw new ServletException(e);
        }

    }
    @Override
    public void doPost (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {
        //get the pdf from the session and return it
    }

}