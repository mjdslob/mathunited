package nl.math4all.mathunited.utils;

import org.apache.commons.exec.*;
import org.apache.commons.exec.environment.EnvironmentUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.output.NullWriter;
import org.apache.commons.io.output.WriterOutputStream;

import java.io.*;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import java.util.Map;
import java.util.logging.Logger;

/**
 * Class to run svn scripts
 * Created by linden on 22/09/15.
 */
public class ScriptRunner {
    static final Logger LOGGER = Logger.getLogger(ScriptRunner.class.getName());
    static final String SHELL = "/bin/zsh";

    Writer writer;
    PrintStream printStream;

    /**
     * Create a stream for the current writer
     */
    void makeStream() {
        WriterOutputStream wos = new WriterOutputStream(writer, Charset.defaultCharset(), 256, true);
        printStream = new PrintStream(wos, true);
    }

    /**
     * Create a script runner that copies script output to a writer
     */
    public ScriptRunner(Writer writer) {
        this.writer = writer;
        makeStream();
    }

    /**
     * Create a script runner that does not copy script output to a writer
     */
    public ScriptRunner() {
        this(new NullWriter());
    }

    /**
     * Exception-less version
     */
    public void runScript(String name, String... args) {
        try {
            runScript(name, false, args);
        } catch (SvnException ex) {
            // Ignore as well.
        }
    }

    /**
     * Run script name.sh (no arguments)
     * @param name The name of the script. The .sh extension will be added.
     */
    public void runScript(String name, boolean exceptions, String... args) throws SvnException {
        // Build command line
        CommandLine sh = new CommandLine(SHELL);

        // Script as string
        String escapedName = null;
        try {
            escapedName = URLEncoder.encode(name, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        // Get the script location in the tomcat app and check that it exists
        URL scriptURL = ScriptRunner.class.getResource("/" + escapedName + ".zsh");
        if (scriptURL == null) {
            String msg = "No such script: " + escapedName + ".zsh";
            if (exceptions) {
                throw new SvnException(msg);
            } else {
                LOGGER.warning(msg);
                return;
            }
        }

        // Turn shell scipt location into string
        String script = scriptURL.getPath();
        sh.addArgument(script);

        // Get shell script command for logging
        String cmd = FilenameUtils.getName(script);
        printStream.printf("--- Executing '%s'%n", cmd);

        // Add any arguments to environment as ARG1, ARG2 etc.
        Map<String, String> env;
        try {
            env = EnvironmentUtils.getProcEnvironment();
        } catch (IOException ex) {
            throw new SvnException(ex);
        }
        for (int i = 0; i < args.length; i++) {
            // Generate name in form of ARG1 etc.
            String varname = String.format("ARG%d", i + 1);

            // Clean up arguments for safety

            // Only forward slashes
            String arg = args[i].replace('\\', '/');

            // Stop if argument contains non-white listed characters or
            // looks like an option, to prevent they are used to do havoc
            // in the shell. Try regex on http://www.regexplanet.com/advanced/java/index.html
            if (arg.matches(".*[\\W&&[^/._-]].*") || arg.startsWith("-")) {
                String msg = "Illegal argument " + Integer.toString(i+1) + ": '" + arg + "'";
                if (exceptions) {
                    throw new SvnException(msg);
                } else {
                    printStream.println("*** ERROR: " + msg);
                    LOGGER.warning(msg);
                    return;
                }
            }
            // Store in environment
            env.put(varname, arg);
        }

        // Timing
        long tic = System.currentTimeMillis();

        // Execute in child process
        DefaultExecuteResultHandler resultHandler = new DefaultExecuteResultHandler();
        Executor executor = new DefaultExecutor();

        // Add a timeout of an hour
        ExecuteWatchdog watchdog = new ExecuteWatchdog(1 * 60 * 60 * 1000 /* 1 hour in milliseconds */);
        executor.setWatchdog(watchdog);

        // Connect I&O
        PumpStreamHandler streamHandler = new PumpStreamHandler(printStream);
        executor.setStreamHandler(streamHandler);

        // Run the command line
        try {
            executor.execute(sh, env, resultHandler);
            resultHandler.waitFor();
        } catch (Exception ex) {
            String message = "Error executing '" + cmd + "': " + ex.getMessage();
            try {
                writer.write("*** " + message + "\n");
            } catch (IOException e) {}
            if (exceptions) {
                throw new SvnException(message, ex);
            } else {
                LOGGER.warning(message);
            }
        } finally {
            // Re-create print stream
            long toc = System.currentTimeMillis();
            try {
                if (watchdog.killedProcess()) {
                    writer.write("*** Process '" + cmd + "' was killed by watchdog after " + (toc - tic) + " ms.\n");
                } else {
                    writer.write("--- '" + cmd + "' took " + (toc - tic) + " ms.\n");
                }
            } catch (IOException ex) {}
        }

        // Return exit code
        if (resultHandler.getExitValue() != 0) {
            String message = "Error executing '''" + sh
                    + "''': Return value was " + resultHandler.getExitValue();
            try {
                writer.write("*** " + message + "\n");
            } catch (IOException ex) {}

            if (exceptions) {
                throw new SvnException(message);
            } else {
                LOGGER.warning(message);
            }
        }

    }

}
