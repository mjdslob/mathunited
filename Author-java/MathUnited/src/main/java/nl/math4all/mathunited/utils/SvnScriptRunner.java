package nl.math4all.mathunited.utils;

import org.apache.commons.exec.*;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.logging.Logger;

/**
 * Class to run svn scripts
 * Created by linden on 22/09/15.
 */
public class SvnScriptRunner {
    public static final Logger LOGGER = Logger.getLogger(SvnScriptRunner.class.getName());

    /**
     * Run script name.sh (no arguments)
     * @param name The name of the script. The .sh extension will be added.
     */
    public void runScript(String name, boolean exceptions) throws SvnException {
        // Build command line
        CommandLine sh = new CommandLine("/bin/sh");

        // Script
        InputStream is = SvnScriptRunner.class.getResourceAsStream(name + ".sh");

        // Timing
        long tic = System.currentTimeMillis();

        // Execute in child process
        DefaultExecuteResultHandler resultHandler = new DefaultExecuteResultHandler();
        Executor executor = new DefaultExecutor();

        // Connect I & O
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        PumpStreamHandler streamHandler = new PumpStreamHandler(bos, bos, is);
        executor.setStreamHandler(streamHandler);

        try {
            executor.execute(sh, resultHandler);
            resultHandler.waitFor();
        } catch (Exception ex) {
            String message = "Error executing '''" + sh + "''': " + ex.getMessage() + "\n" + bos.toString();
            if (exceptions) {
                throw new SvnException(message, ex);
            } else {
                LOGGER.warning(message);
            }
        }
        finally {
            long toc = System.currentTimeMillis();
            LOGGER.info("'" + sh + "' took " + (toc - tic) + " ms.");
        }

        // Return exit code
        if (resultHandler.getExitValue() != 0) {
            String message = "Error executing '''" + sh
                    + "''': Return value was " + resultHandler.getExitValue() + "\n"
                    + bos.toString();
            if (exceptions) {
                throw new SvnException(message);
            } else {
                LOGGER.warning(message);
            }
        }

    }

}
