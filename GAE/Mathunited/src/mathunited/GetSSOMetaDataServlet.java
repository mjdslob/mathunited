package mathunited;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.Writer;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class GetSSOMetaDataServlet extends HttpServlet {
	private static final long serialVersionUID = 5117696029378587701L;

	private final static Logger LOGGER = Logger.getLogger(GetSSOMetaDataServlet.class.getName());
    ServletContext context;

    public void init(ServletConfig config) throws ServletException {
        try{
            super.init(config);
            context = getServletContext();
        } catch(Exception e) {
        	LOGGER.severe((new StringBuilder("Init of GetTextFileServlet failed")).append(e.getMessage()).toString());
        }
    }

    @Override
    public void doGet (  HttpServletRequest request, HttpServletResponse response)
             throws ServletException, IOException {
	   
	   LOGGER.setLevel(Level.INFO);

	   try{
		   String sp = request.getParameter("sp");
		   if(sp==null){
               throw new Exception("Missing sp parameter");
		   }
		   
		   String metaDataTemplateFilename = "";
		   
		   if (sp.equals("studiovo"))
		   {
			   metaDataTemplateFilename = "/sources_studiovo/ssometa.xml";
		   }			   

		   InputStream is = context.getResourceAsStream(metaDataTemplateFilename);
		   try
		   {
	 		   // Specify domains from which requests are allowed
			   response.addHeader("Access-Control-Allow-Origin", "*");
	 	       // Specify which request methods are allowed
			   response.addHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
			   // Additional headers which may be sent along with the CORS request
			   // The X-Requested-With header allows jQuery requests to go through
			   response.addHeader("Access-Control-Allow-Headers", "X-Requested-With");
			   response.setContentType("text/xml");
			   
//			   CertificateFactory factory2 = CertificateFactory.getInstance("X.509");
//			   Certificate generateCertificate = factory2.generateCertificate(context.getResourceAsStream("/sources_studiovo/studiovo-saml2.cer"));
//			   String b64 = Base64.encodeBase64String(generateCertificate.getPublicKey().getEncoded());
//	           Writer w = response.getWriter();
//	           PrintWriter pw = new PrintWriter(w);
//	           pw.println(b64);
			   
			   ServletOutputStream out = response.getOutputStream();
			   try
			   {
				   copy(is,out);
			   }
			   finally
			   {
				   out.close();
			   }
		   }
		   finally
		   {
			   is.close();
		   }
	   } catch (Exception e) {
           e.printStackTrace();
           Writer w = response.getWriter();
           PrintWriter pw = new PrintWriter(w);
           pw.println("error: "+e.getMessage());
           throw new ServletException(e);
       }
   } 
    
    private static void copy(InputStream in, OutputStream out) throws IOException
    {
    	byte[] buffer = new byte[1024];
    	int len;
    	while ((len = in.read(buffer)) != -1) {
    	    out.write(buffer, 0, len);
    	}
    }

}
