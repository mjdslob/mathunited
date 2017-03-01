package nl.math4all.mathunited.utils;

import java.io.PrintWriter;
import java.util.logging.Logger;

/**
 * This is the classical file lock that was used before subversion.
 * The presence of this file would be checked.
 * Created by linden on 8-12-14.
 */
public class SvnLock extends Lock {
    /** Log with proper prefix. */
    public static final Logger LOGGER = Logger.getLogger(FileLock.class.getName());

    /**
     * Create a Lock Entry and set timestamp to now.
     *
     * @param refbase Directory to lock
     * @param username Under which username the lock should be made
     */
    SvnLock(String refbase, String username) {
        super(refbase, username);
    }

    /**
     * Acquire lock.
     *
     * A lock exception is thrown if anything that could corrupt content is encountered.
     * For example, if the contents of the directory cannot be updated, and so we are
     * not sure if the user will edit the latest content. Also when the files cannot
     * be locked in the subversion repo, a lock exceptions is thrown.
     */
    public void aquire() throws LockException {
        //LOGGER.info("Locking (svn)" + refbase + " for user " + username + ".");

        // Remove stale lock file
        removeLockFile();

        // Update with script
        ScriptRunner runner = new ScriptRunner(new PrintWriter(System.out));
        runner.runScript("svn-update-paragraph", refbase, username);

        // Create new persistent lock file
        createLockFile();

    }

    /** Release lock */
    public void release() throws LockException {
        //LOGGER.info("Releasing lock (svn) for " + refbase + " for user " + username + ".");

        // Remove the lock file
        removeLockFile();
    }
}
