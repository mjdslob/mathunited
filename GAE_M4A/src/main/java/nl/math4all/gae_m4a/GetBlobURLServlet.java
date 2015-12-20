// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   GetBlobURLServlet.java

package nl.math4all.gae_m4a;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import java.util.logging.Logger;

public class GetBlobURLServlet extends HttpServlet {
        private final static Logger LOGGER = Logger.getLogger(GetBlobURLServlet.class.getName());

	private static final long serialVersionUID = -1185194851400641339L;

	public GetBlobURLServlet()  {
        blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
    }

    public void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException   {
        try   {
            java.io.Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            String url = blobstoreService.createUploadUrl("/putresource");
            pw.println(url);
        } catch(Exception e) {
            LOGGER.severe(e.getMessage());
            e.printStackTrace();
            java.io.Writer w = response.getWriter();
            PrintWriter pw = new PrintWriter(w);
            pw.println((new StringBuilder("error: ")).append(e.getMessage()).toString());
            throw new ServletException(e);
        }
    }

    private BlobstoreService blobstoreService;
}
