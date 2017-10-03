package nl.math4all.mathunited;

import java.io.*;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.*;
import javax.servlet.http.*;
import nl.math4all.mathunited.configuration.*;
import nl.math4all.mathunited.editor.WorkflowServlet;
import nl.math4all.mathunited.utils.Utils;


//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class AkitGenerate extends HttpServlet {
    String appId = "math4all-site";
    String appSecret = "c321b556-ed9c-4f6d-87a3-faeeda976e3b";
    String courseId = "mathforall";
    String URLBase = "https://algebrakit.eu";
    
    @Override
    public void init(ServletConfig config) throws ServletException {
         super.init(config);
    }


    @Override
    public void doGet (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {

        try{
            // Read request parameters
            Map<String, String> parameterMap = Utils.readParameters(request);
            String exId = parameterMap.get("exercise-id");
            if(exId==null) throw new Exception("No exercise id supplied.");
            
            String withSolutionStr = parameterMap.get("with-solution");
            boolean withSolution = withSolutionStr!=null && withSolutionStr.equals("true");
            
            Map<String, Object> httpParams = new HashMap<>();
            httpParams.put("appId", appId);
            httpParams.put("appSecret", appSecret);
            httpParams.put("courseId", courseId);
            httpParams.put("exerciseId", exId);
//            Map<String, Object> options = new HashMap<>();
//            options.put("renderFormat", "MATHML");
//            httpParams.put("options", options);
            
//            if(withSolution) httpParams.put("withSolution", "true");
            String resp = Utils.httpPost(URLBase + "/exercise/generate/cms", httpParams);
            response.setContentType("application/json");
            Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            pw.println(resp);
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