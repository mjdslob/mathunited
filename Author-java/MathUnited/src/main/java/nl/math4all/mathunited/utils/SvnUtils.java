package nl.math4all.mathunited.utils;

import nl.math4all.mathunited.configuration.Configuration;
import org.apache.commons.exec.*;
import org.apache.commons.io.IOCase;
import org.apache.commons.io.filefilter.WildcardFileFilter;
import org.apache.commons.lang3.ArrayUtils;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileFilter;
import java.util.logging.Logger;

/**
 * Created by linden on 13-12-14.
 */
public class SvnUtils {
    public static final String SVN_REPO_ROOT = Configuration.getInstance().getSvnRepoRoot();
    public static final Logger LOGGER = Logger.getLogger(SvnUtils.class.getName());

    public static boolean hasSubversion() {
        return (SvnUtils.SVN_REPO_ROOT != null && !SvnUtils.SVN_REPO_ROOT.isEmpty());
    }

    public static String[] svnFilesForPath(String path) {
        File dir = new File(path);
        FileFilter ff = new WildcardFileFilter("*.xml", IOCase.INSENSITIVE);
        File[] files = dir.listFiles(ff);
        if (files == null) {
            LOGGER.warning("Unexpected null in call to listFiles. Is path " + path +" correct?");
            files = new File[0];
        }

        // Convert files to strings
        String[] filePaths = new String[files.length];
        for (int i = 0; i < filePaths.length; i++) {
            filePaths[i] = files[i].toString();
        }

        return filePaths;
    }

    public static void svn(boolean exceptions, String[] files, String... args) throws SvnException {
        svn(exceptions, ArrayUtils.addAll(args, files));
    }

    public static void svn(boolean exceptions, String... args) throws SvnException {
        // Build command line
        CommandLine cmd = new CommandLine("svn");
        for (String arg : args) {
            cmd.addArgument(arg);
        }

        LOGGER.info("Command line = '''" + cmd + "'''.");
        long tic = System.currentTimeMillis();

        // Execute in child process
        DefaultExecuteResultHandler resultHandler = new DefaultExecuteResultHandler();
        Executor executor = new DefaultExecutor();

        // Capture output
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        PumpStreamHandler streamHandler = new PumpStreamHandler(bos);
        executor.setStreamHandler(streamHandler);

        try {
            executor.execute(cmd, resultHandler);
            resultHandler.waitFor();
        } catch (Exception ex) {
            String message = "Error executing '''" + cmd + "''': " + ex.getMessage() + "\n" + bos.toString();
            if (exceptions) {
                throw new SvnException(message, ex);
            } else {
                LOGGER.warning(message);
            }
        }
        finally {
            long toc = System.currentTimeMillis();
            LOGGER.info("'" + cmd + "' took " + (toc - tic) + " ms.");
        }

        // Return exit code
        if (resultHandler.getExitValue() != 0) {
            String message = "Error executing '''" + cmd
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
