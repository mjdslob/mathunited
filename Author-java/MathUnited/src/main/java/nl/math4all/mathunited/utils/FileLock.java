package nl.math4all.mathunited.utils;

import java.util.logging.Logger;

/**
 * This is the classical file lock that was used before subversion.
 * The presence of this file would be checked.
 * Created by linden on 8-12-14.
 */
public class FileLock extends Lock {
    public static final Logger LOGGER = Logger.getLogger(FileLock.class.getName());

    /**
     * Create a Lock Entry and set timestamp to now.
     *
     * @param refbase
     * @param username
     */
    FileLock(String refbase, String username)  {
        super(refbase, username);
    }

    /** Acquire lock. */
    public void aquire() throws LockException {
        LOGGER.info("Locking (svn)" + refbase + " for user " + username + ".");

        // Check if directory has already been locked before (e.g. after a server restart)
        removeLockFile();

        // Create new persistent lock file
        createLockFile();
    }

    /** Release lock */
    public void release() {
        LOGGER.info("Locking (svn)" + refbase + " for user " + username + ".");
        removeLockFile();
    }
}
