package nl.math4all.mathunited.utils;

/**
 * Created by linden on 10-12-14.
 */
public class SvnException extends Exception {
    public SvnException(String message) {
        super(message);
    }

    public SvnException(Throwable cause) {
        super(cause);
    }

    public SvnException(String message, Throwable cause) {
        super(message, cause);
    }
}
