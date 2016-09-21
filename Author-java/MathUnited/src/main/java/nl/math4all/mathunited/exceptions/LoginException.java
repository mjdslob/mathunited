package nl.math4all.mathunited.exceptions;

/**
 *
 * @author martijnslob
 */
public class LoginException extends MathUnitedException {
    public LoginException() {
        super();
    }
    public LoginException(String msg) {
        super(msg);
    }
    public LoginException(String msg, Exception cause) {
        super(msg,cause);
    }
    
}
