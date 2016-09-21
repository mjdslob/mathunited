package nl.math4all.mathunited.exceptions;

/**
 *
 * @author martijnslob
 */
public class ConfigException extends MathUnitedException {
    public ConfigException() {
        super();
    }
    public ConfigException(String msg) {
        super(msg);
    }
    public ConfigException(String msg, Exception cause) {
        super(msg,cause);
    }
    
}
