package nl.math4all.mathunited.utils;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;

import java.io.File;
import java.io.IOException;
import java.util.logging.Logger;

/**
 * Created by linden on 8-12-14.
 */
public abstract class Lock {
    public String getRefbase() {
        return refbase;
    }

    public String getUsername() {
        return username;
    }

    public long getTimestamp()  { return timestamp; }

    String refbase;
    String username;
    long timestamp;

    static Logger LOGGER = Logger.getLogger(Lock.class.getName());

    /** Create a Lock Entry and set timestamp to now. */
    Lock(String refbase, String username) {
        if (StringUtils.isEmpty(refbase) || StringUtils.isEmpty(username)) {
            LOGGER.warning("Refbase or username is empty");
        }
        // Make sure refbase ends with /
        refbase = LockManager.normalizeRefbaseName(refbase);
        this.refbase = refbase;
        this.username = username;
        this.timestamp = System.currentTimeMillis();
    }

    /** Update timestamp to now. */
    public void touch() {
        this.timestamp = System.currentTimeMillis();
    }

    /** Get the lock file corresponding to this lock. */
    public File getLockFile() {
        return new File(refbase, LockManager.LOCK_FILE_NAME);
    }

    /** Create a lock file */
    public void createLockFile() throws LockException {
        try {
            FileUtils.writeStringToFile(getLockFile(), username);
        } catch (IOException e) {
            throw new LockException("Error creating lock file", e);
        }
    }

    /** Remove a lock file */
    public void removeLockFile() {
        getLockFile().delete();
    }

    /** Perform actions to activate the lock. */
    public abstract void aquire() throws LockException;

    /** Perform clean up actions to release the lock. */
    public abstract void release() throws LockException ;
}
