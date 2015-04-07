package nl.math4all.mathunited.utils;

import nl.math4all.mathunited.configuration.Configuration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.FileFilterUtils;
import org.apache.commons.io.filefilter.IOFileFilter;

import java.io.File;
import java.io.IOException;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

/**
 * Created by linden on 7-12-14.
 */
public class LockManager {
    /** Maximum time before lock can be stolen. */
    private static final int MAX_LOCK_DURATION_MS = 60000;

    /** Name of lock files */
    public static final String LOCK_FILE_NAME = "lock";

    /** Logger */
    private final static Logger LOGGER = Logger.getLogger(LockManager.class.getName());

    /** Singleton pattern. */
    public static final LockManager INSTANCE = new LockManager();

    /** Singleton pattern. */
    public static LockManager getInstance() {
        return INSTANCE;
    }

    /** Lock locations to user and timestamp information. */
    ConcurrentHashMap<String, Lock> locks = new ConcurrentHashMap<>();

    /**
     * Timer for cleaning stale locks.
     * @note Avoid java's Timer as it does not work well with restarting servlets
     */
    ScheduledExecutorService timer = Executors.newSingleThreadScheduledExecutor();

    /** Whether svn is present. */
    boolean useSubversion = SvnUtils.hasSubversion();


    /**
     * Look for stale lock and put them back into the map.
     * This happens after a server restart of update. We the lose the state in
     * the locks map, so this state has to be rebuild.
     */
    private void fillLockMapWithStaleLocks() {
        File contentRoot = new File(Configuration.getInstance().getContentRoot());
        IOFileFilter lockName = FileFilterUtils.nameFileFilter(LOCK_FILE_NAME);
        IOFileFilter doSubdirs = FileFilterUtils.trueFileFilter();

        // Find all lock files
        Collection<File> lockFiles = FileUtils.listFiles(contentRoot, lockName, doSubdirs);

        // Add previous locks to locks map
        for (File f : lockFiles) {
            String refbase = f.getParent();
            try {
                String username = FileUtils.readFileToString(f);
                locks.put(refbase, newLock(refbase, username));
            } catch (IOException e) {
                LOGGER.warning("!!! Problems processing lock file '" + f + "': " + e.getMessage());
            }
        }
    }

    /** Class that periodically checks if locks have a timeout and calls release() on those locks. */
    private class LockTimeoutChecker implements Runnable {
        @Override
        public void run() {
            try {
                final long now = System.currentTimeMillis();

                Iterator<Map.Entry<String,Lock>> it = locks.entrySet().iterator();

                while (it.hasNext()) {
                    Map.Entry<String,Lock> entry = it.next();
                    Lock lock = entry.getValue();

                    LOGGER.info("Checking " + lock.refbase + " dt = " + (now - lock.timestamp));
                    if (now - lock.timestamp > MAX_LOCK_DURATION_MS) {
                        try {
                            lock.release();
                        } catch (LockException e) {
                            LOGGER.warning("Error while releasing lock: " + e.getMessage());
                        }
                        locks.remove(entry.getKey());
                    }
                }
            } catch (Exception t) {
                // Catch any thing to prevent a lock-down
                LOGGER.warning("!!! CAUGHT UNEXPECTED EXCEPTION: " + t.getMessage());
            }
        }
    }

    /** Private constructor to enforce singleton pattern */
    private LockManager() {
        // Add stale locks
        fillLockMapWithStaleLocks();

        // Setup release cycle
        timer.scheduleAtFixedRate(new LockTimeoutChecker(), MAX_LOCK_DURATION_MS, MAX_LOCK_DURATION_MS / 4, TimeUnit.MILLISECONDS);
    }

    /** Create a new lock for given paragraph directory and username. */
    private Lock newLock(String refbase, String username) {
        Lock lock;
        if (useSubversion) {
            lock = new SvnLock(refbase, username);
        } else {
            lock = new FileLock(refbase, username);
        }
        return lock;
    }

    /** Tries to7 get the lock on this subcomponent.
     * @param username
     * @param refbase
     * @return null if lock is obtained. If the lock is owned by some other user, the
     *         username of this current owner is returned.
     */
    public String getLock(String username, String refbase) {
        LOGGER.info("Requesting lock for user " + username + " for path '" + refbase + "'");

        // Put in synchronized block because there is time between checking existing lock and adding new
        synchronized (locks) {
            // Check if refbase is being locked already
            Lock lockData = locks.get(refbase);
            if (lockData != null) {
                if (Objects.equals(lockData.username, username)) {
                    LOGGER.info("Updating lock timestamp for " + refbase + ", user " + username);
                    lockData.touch();
                } else {
                    LOGGER.info("Editing not allowed: lock for " + refbase + " is currently owned by " + lockData.username);
                }
                return lockData.username;
            }

            // Create lock
            LOGGER.info("Creating new lock on " + refbase + " for user " + username);

            try {
                Lock lock = newLock(refbase, username);
                lock.aquire();
                locks.put(refbase, lock);

                LOGGER.info("Lock was created succesfully");
            } catch (LockException e) {
                LOGGER.info("Could not create lock, assuming locked by XML editor: " + e.getMessage());
                return "@@@" + e.getMessage();
            }
        }

        // Return username
        return username;
    }

}

