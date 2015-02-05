package nl.math4all.mathunited.utils;

import java.io.File;
import java.io.IOException;
import java.util.*;
import java.util.logging.Logger;

/**
 * This is the classical file lock that was used before subversion.
 * The presence of this file would be checked.
 * Created by linden on 8-12-14.
 */
public class SvnLock extends Lock {
    /** Remember which files were locked to see which files need to be "svn add"-ed. */
    String[] lockedFiles = new String[0];

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
        LOGGER.info("Locking (svn)" + refbase + " for user " + username + ".");

        // Remove stale lock file
        removeLockFile();

        // Update
        try {
            SvnUtils.svn(true, "update", refbase);
        } catch (SvnException e) {
            throw new LockException("Could not update " + refbase, e);
        }

        // Create new persistent lock file
        createLockFile();

        // Get list of files we need to lock
        lockedFiles = SvnUtils.svnFilesForPath(refbase);

        // No need to lock files in empty directory
        if (lockedFiles.length == 0) {
            return;
        }

        // Lock the files
        try {
            // Lock files
            SvnUtils.svn(true, lockedFiles, "lock");
        } catch (Exception e) {
            throw new LockException("Could not acquire lock", e);
        }
    }

    /** Release lock */
    public void release() throws LockException {
        LOGGER.info("Releasing lock (svn) for " + refbase + " for user " + username + ".");

        // Get list of files that are lockable
        String[] files = SvnUtils.svnFilesForPath(refbase);

        // Get list of new files
        HashSet<String> newFileSet = new HashSet<>(Arrays.asList(files));
        newFileSet.removeAll(Arrays.asList(lockedFiles));
        String[] newFiles = newFileSet.toArray(new String[0]);

        System.out.println("Release:: locked files: ");
        for (String f : lockedFiles) {
            System.out.println("-- " + f);
        }

        System.out.println("Release:: new files: ");
        for (String f : newFiles) {
            System.out.println("-- " + f);
        }

        // Commit the files the files
        try {
            // Add new files (ignore errors, add missing parent directories)
            SvnUtils.svn(false, newFiles, "add", "--parents");

            // Commit will unlock
            SvnUtils.svn(false, "commit", refbase, "-m", "Changes by user " + username + ".");

            // Commit images
            File imagedir = new File(refbase, "../images");
            if (imagedir.exists()) {
                try {
                    String imagepath = imagedir.getCanonicalPath();
                    SvnUtils.svn(false, "add", "--force", imagepath);
                    SvnUtils.svn(false, "commit", imagepath, "-m", "Changed images by user " + username + ".");
                } catch (IOException e) {
                    // Warn, but ignore errors
                    LOGGER.warning("Failed to add images: " + e.getMessage());
                }
            }

            // Explicitly unlock files in case no changes were made
            if (lockedFiles.length > 0) {
                SvnUtils.svn(false, lockedFiles, "unlock");
            }

            // Remove the lock file
            File lockFile = new File(refbase, "lock");
            if (lockFile.exists()) {
                lockFile.delete();
            }

        } catch (SvnException e) {
            throw new LockException("Could not release lock", e);
        }
    }
}
