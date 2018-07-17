package nl.math4all.gae_m4a;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.Writer;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLDecoder;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.bind.DatatypeConverter;


//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class GeogebraGenerator extends HttpServlet {

	private static final long serialVersionUID = 8160691505447446635L;
	
	private final static Logger LOGGER = Logger.getLogger(GeogebraGenerator.class.getName());
        String ggbSource = "web.geogebra.org/4.2/web/web.nocache.js";
//    String ggbSource = "http://www.geogebra.org/web/4.2/web/web.nocache.js";

    @Override
    public void init(ServletConfig config) throws ServletException {
         LOGGER.setLevel(Level.INFO);
         super.init(config);
    }


    @Override
    public void doGet (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {
        Writer w = response.getWriter();
        PrintWriter pw = new PrintWriter(w);
        try{
            String fname = request.getParameter("file");
            if(fname==null) {
                throw new Exception("Please supply a filename");
            }
            fname = URLDecoder.decode(fname,"UTF-8");
            if(!fname.contains("blob-key")) fname+="&type=ggb";
            
            String protocol = "http://";
            if(request.getRequestURL().toString().contains("https://")) {
            	fname=fname.replace("/getresource?", "/getresource_s?");
                protocol = "https://";
                LOGGER.info("Using https: url="+protocol+request.getServerName()+fname);
            }
            String urlname = protocol+request.getServerName()+fname;
            LOGGER.info("Geogebra generator: retrieving Geogebra file from "+urlname);
            URL url = new URL(urlname);
            URLConnection conn = url.openConnection();
            int length = conn.getContentLength();
            byte[] b;
            if(length>-1) {
                b = new byte[length];
                InputStream is = url.openStream();
                is.read(b);
                is.close();
            } else {
                InputStream is = url.openStream();
                BufferedInputStream bis = new BufferedInputStream(is);
                ByteArrayOutputStream bos = new ByteArrayOutputStream();

                int count;
                byte buffer[] = new byte[1024];

                while ((count = bis.read(buffer, 0, buffer.length)) != -1){
                    bos.write(buffer, 0, count);
                }
                b = bos.toByteArray();
                bis.close();
                bos.close();
            }
            String b64 = DatatypeConverter.printBase64Binary(b);
            response.setContentType("text/html");
            pw.println("<html style='overflow:hidden'><head><style type='text/css'><!--body { font-family:Arial,Helvetica,sans-serif; margin-left:40px }--></style><script type='text/javascript' language='javascript' src='"+protocol+ggbSource+"'></script></head>");
            pw.println("<body><article class='geogebraweb' style='display:inline-block;' data-param-ggbbase64='"+b64+"'></article>");
            pw.println("<script type='text/javascript'>var ggbApplet = document.ggbApplet;function ggbOnInit() {}</script></body></html>");
        } catch(Exception e) {
            pw.println("An error occured: "+e.getMessage());
            e.printStackTrace();
        }
    }



    @Override
    public void doPost (  HttpServletRequest request,
                         HttpServletResponse response)
             throws ServletException, IOException {
        //get the pdf from the session and return it
    }

}