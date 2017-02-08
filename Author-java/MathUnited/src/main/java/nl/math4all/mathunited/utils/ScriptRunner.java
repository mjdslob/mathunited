package nl.math4all.mathunited.utils;

import org.apache.commons.io.output.NullWriter;

import java.io.Writer;
import java.util.concurrent.locks.*;

/**
 * Class to run svn scripts
 * Created by linden on 22/09/15.
 */
public class ScriptRunner extends UnfencedScriptRunner {

    private static java.util.concurrent.locks.Lock lock = new ReentrantLock();

    /**
     * Create a script runner that copies script output to a writer
     */
    public ScriptRunner(Writer writer) {
        super(writer);
    }

    /**
     * Create a script runner that does not copy script output to a writer
     */
    public ScriptRunner() {
        this(new NullWriter());
    }

    /**
     * Run script name.zsh (no arguments). This version only runs one at a time.
     * @param name The name of the script. The .zsh extension will be added.
     * @param exceptions whether to throw exceptions
     * @param args Optional arguments to to script
     */
    @Override
    public void runScript(String name, boolean exceptions, String... args) throws SvnException {
        lock.lock();
        try {
            super.runScript(name, exceptions, args);
        } finally {
            lock.unlock();
        }
    }

}
