package nl.math4all.mathunited;

import org.apache.commons.io.IOUtils;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class VersionServlet extends HttpServlet {
    private String version_txt = "";

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);

        // Copy resource file to string
        StringWriter writer = new StringWriter();
        try {
            IOUtils.copy(getServletContext().getResourceAsStream("/WEB-INF/classes/version.txt"), writer);
            version_txt = writer.toString();
        } catch (IOException e) {
            e.printStackTrace();
        }

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
        response.setContentType("text/plain");


        Writer w = response.getWriter();
        PrintWriter pw = new PrintWriter(w);

        pw.println(version_txt);
    }
    

}