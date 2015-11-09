package nl.math4all.mathunited.editor;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Created by linden on 03/11/15.
 */
public class BaseHttpServlet extends HttpServlet {

    private final static Logger LOGGER = Logger.getLogger(SvnUpdateServlet.class.getName());

    ServletContext context;

    @Override
    public void init(ServletConfig config) throws ServletException {
        try {
            super.init(config);
            context = getServletContext();
            LOGGER.setLevel(Level.INFO);
        } catch (Exception e) {
            e.printStackTrace();
            LOGGER.log(Level.SEVERE, e.getMessage());
        }
    }
}
