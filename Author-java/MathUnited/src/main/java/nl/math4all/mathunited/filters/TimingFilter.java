package nl.math4all.mathunited.filters;

import nl.math4all.mathunited.configuration.UserSettings;
import nl.math4all.mathunited.exceptions.MathUnitedException;
import nl.math4all.mathunited.utils.UserManager;
import nl.math4all.mathunited.utils.Utils;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Created by linden on 21/09/2016.
 */
public class TimingFilter implements Filter {

    @Override
    public void destroy() {
        // do nothing...
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // do nothing...
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        // Wrap real processing with ms accurate timers
        long tic = System.currentTimeMillis();
        filterChain.doFilter(servletRequest, servletResponse);
        long toc = System.currentTimeMillis() - tic;

        // If timing is short (< 10 ms) ignore. Not to clutter the logs too much (e.g. with serving
        // css, images etc.)
        if (toc < 10) {
            return;
        }

        // Get the name of the servlet request if possible
        StringBuilder builder = new StringBuilder();
        builder.append("[TIMING] Servlet ");

        if (servletRequest instanceof HttpServletRequest) {
            HttpServletRequest request = (HttpServletRequest) servletRequest;
            builder.append(request.getRequestURI());

            // See if component info is available
            try {
                for (String key : new String[] {"comp", "subcomp", "variant"}) {
                    String val = Utils.readParameter(key, true, request);
                    builder.append(' ');
                    builder.append(key);
                    builder.append('=');
                    builder.append(val);
                }
            } catch (Exception e){
                // ignore...
            }

            // See if user info is available
            try {
                UserSettings usettings = UserManager.isLoggedIn(request, (HttpServletResponse) servletResponse);
                builder.append(" for user=");
                builder.append(usettings.username);
            } catch (MathUnitedException e) {
                // ignore...
            }
        }

        builder.append(" took ");
        builder.append(toc);
        builder.append(" ms.");


        // Only log long operations (>= 10 ms). We put this filter to avoid static
        // content (css, images) to end up in the log.
        System.out.println(builder.toString());
    }
}
