package nl.math4all.mathunited.utils;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Logger;

/**
 * Created by linden on 8-12-14.
 */
public class Lock {

    String refbase;
    String username;
    long timestamp;

    public static long TIMESTAMP_NEVER = 0;
    public static long TIMESTAMP_FAILED = -1;

    private long sessionStart;
    private long lastUpdate = TIMESTAMP_NEVER;
    private long lastCommit = TIMESTAMP_NEVER;
    private boolean active = false;


    private static Logger LOGGER = Logger.getLogger(Lock.class.getName());

    /** Create a Lock Entry and set timestamp to now. */
    Lock(String refbase, String username) {
        if (StringUtils.isEmpty(refbase) || StringUtils.isEmpty(username)) {
            LOGGER.warning("Refbase or username is empty");
        }

        // Make sure refbase ends with a slash (/)
        refbase = LockManager.normalizeRefbaseName(refbase);
        this.refbase = refbase;
        this.username = username;
        this.timestamp = System.currentTimeMillis();
        this.sessionStart = timestamp;
    }

    /** Update timestamp to now. */
    public void touch() {
        this.timestamp = System.currentTimeMillis();
    }

    /** Perform actions to activate the lock. */
    public void aquire() throws LockException {
        active = true;
    }

    /** Perform clean up actions to release the lock. */
    public void release() throws LockException {
        active = false;

        ScriptRunner runner = new ScriptRunner(new PrintWriter(System.out));
        try {
            runner.runScript("svn-unlock-paragraph", true, refbase, username);
        } catch (SvnException e) {
            LOGGER.warning("svn-unlock-paragraph on " + refbase + " for user " + username + " failed.");
        }

    }

    /**
     * Is this lock active or stale?
     */
    public boolean isActive() {
        return active;
    }

    /**
     * Get the path that is locked by this lock
     * @return String with path information
     */
    public String getRefbase() {
        return refbase;
    }

    /**
     * Get the user name that owns current lock
     * @return String with user name
     */
    public String getUsername() {
        return username;
    }

    /**
     * Get the last lock refresh time stamp
     * @return System.currentTimeMillis() of last refresh
     */
    public long getTimestamp()  {
        return timestamp;
    }

    /**
     * Inform that content has been updated from external source
     */
    public void updated() {
        lastUpdate = System.currentTimeMillis();
    }

    /**
     * Inform that content update from external source has failed
     */
    public void updateFailed() {
        lastUpdate = TIMESTAMP_FAILED;
    }

    /**
     * Get time of last update
     * @return System.currentTimeMillis() of last content update
     */
    public long getLastUpdate() {
        return lastUpdate;
    }

    /**
     * Get time of first lock request
     * @return System.currentTimeMillis() of session start
     */
    public long getSessionStart() {
        return sessionStart;
    }

    /**
     * Inform that content has been committed to external repo
     */
    public void committed() {
        lastCommit = System.currentTimeMillis();
    }

    /**
     * Inform that content has been updated from external source
     */
    public void commitFailed() {
        lastCommit = TIMESTAMP_FAILED;
    }

    /**
     * Get time of last commit
     * @return System.currentTimeMillis() of last content update
     */
    public long getLastCommit() {
        return lastCommit;
    }

}
