package nl.math4all.gae_m4a;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import javax.net.ssl.SSLContext;
import org.apache.commons.io.IOUtils;

public class AkitGenerate extends HttpServlet {
    static final String appId = "math4all-site";
    static final String appSecret = "c321b556-ed9c-4f6d-87a3-faeeda976e3b";
    static URL url;
    
    String GENERATE_REQ_TEMPLATE = "{"
            + "   \"appId\": \"" + appId + "\", "
            + "   \"appSecret\": \"" + appSecret + "\", "
            + "   \"api-version\": 2, "
            + "   \"exercises\": [${EXERCISE_SPEC}]"
            + "}";

    private final static Logger LOGGER = Logger.getLogger(XSLTbean.class.getName());
    private static final long serialVersionUID = 7448591788669617325L;
    static {
        LOGGER.setLevel(Level.INFO);
        try {
            url = new URL("https://algebrakit.eu/exercise/generate");
//            url = new URL("http://localhost:3000/exercise/generate");
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void doOptions(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        //The following are CORS headers. Max age informs the 
        //browser to keep the results of this call for 1 day.
//        resp.setHeader("Access-Control-Allow-Origin", "*");
//        resp.setHeader("Access-Control-Allow-Methods", "GET, POST");
//        resp.setHeader("Access-Control-Allow-Headers", "Content-Type");
//        resp.setHeader("Access-Control-Max-Age", "86400");
//        //Tell the browser what requests we allow.
//        resp.setHeader("Allow", "GET, HEAD, POST, TRACE, OPTIONS");
    }    
    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (BufferedReader br = new BufferedReader(new InputStreamReader(request.getInputStream(), "UTF-8"))) {
//		String inputStr = br.lines().collect(Collectors.joining(System.lineSeparator()));
                StringBuilder buf = new StringBuilder();
                String line = br.readLine();
                while(line!=null) {
                    buf.append(line);
                    line = br.readLine();
                }
                String inputStr = buf.toString();
                String req = GENERATE_REQ_TEMPLATE.replace("${EXERCISE_SPEC}", inputStr);
                
                HttpURLConnection con = (HttpURLConnection) url.openConnection();
                con.setRequestMethod("POST");
                con.setUseCaches(false);
                con.setRequestProperty("Content-Type", "application/json");
                con.setConnectTimeout(5000);
                con.setReadTimeout(5000);
                con.setDoOutput(true);
                DataOutputStream out = new DataOutputStream(con.getOutputStream());
                out.writeBytes(req);
                out.flush();
                out.close();
                
                response.setContentType("application/json; charset=utf-8");
//                response.setHeader("Access-Control-Allow-Origin", "*");
//                response.setHeader("Access-Control-Allow-Methods", "GET, POST");
//                response.setHeader("Access-Control-Allow-Headers", "Content-Type");
//                response.setHeader("Access-Control-Max-Age", "86400");
//                //Tell the browser what requests we allow.
//                response.setHeader("Allow", "GET, HEAD, POST, TRACE, OPTIONS");

                IOUtils.copy(con.getInputStream(),response.getOutputStream());
                
        } catch (Exception e) {
            e.printStackTrace();
            Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            pw.println("error: " + e.getMessage());
            throw new ServletException(e);
        }
    }

}
