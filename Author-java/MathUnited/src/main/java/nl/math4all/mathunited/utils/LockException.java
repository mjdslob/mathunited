package nl.math4all.mathunited.utils;

/**
 * Created by linden on 10-12-14.
 */
public class LockException extends Exception {
    public LockException(String message) {
        super(message);
    }

    public LockException(Throwable cause) {
        super(cause);
    }

    public LockException(String message, Throwable cause) {
        super(message, cause);
    }
}
