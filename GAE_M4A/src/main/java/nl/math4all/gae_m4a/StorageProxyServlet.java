package nl.math4all.gae_m4a;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.Writer;
import java.net.URL;
import java.net.URLConnection;
import java.util.Map;
import java.util.logging.Logger;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class StorageProxyServlet extends HttpServlet {

    private static final long serialVersionUID = -4417747590607632582L;

    ServletContext context;
    private final static Logger LOGGER = Logger.getLogger(XSLTbean.class.getName());

    @Override
    public void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {
            //read request parameters
            @SuppressWarnings("unchecked")
            Map<String, String[]> paramMap = request.getParameterMap();
            String[] strarr = paramMap.get("cmd");
            if (strarr == null || strarr.length == 0) {
                throw new Exception("No command supplied");
            }

            String url = "http://m4a-storage.appspot.com/" + strarr[0];
            boolean isFirst = true;
            for (Map.Entry<String, String[]> entry : paramMap.entrySet()) {
                String pname = entry.getKey();
                String[] pvalArr = entry.getValue();
                if (!pname.equals("cmd") && pvalArr != null && pvalArr.length > 0) {
                    if (isFirst) {
                        url = url + "?" + pname + "=" + pvalArr[0];
                        isFirst = false;
                    } else {
                        url = url + "&" + pname + "=" + pvalArr[0];
                    }
                }
            }

            LOGGER.info("Forward to url: " + url);

            URL website = new URL(url);
            URLConnection connection = website.openConnection();
            BufferedReader in = new BufferedReader(
                    new InputStreamReader(
                            connection.getInputStream()));

            StringBuilder str = new StringBuilder();
            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                str.append(inputLine);
            }
            in.close();

            response.setContentType("application/xml");
            Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            pw.println(str.toString());
        } catch (Exception e) {
            e.printStackTrace(response.getWriter());
            response.setContentType("text/html");
            Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            pw.println("<html><head></head><body><h1>Fout opgetreden</h1><p>");
            pw.println(e.getMessage());
            pw.println("</p></body></html>");
            throw new ServletException(e);
        }
    }

    @Override
    public void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        //get the pdf from the session and return it
    }

}
