package nl.math4all.mathunited.utils;

import java.util.Map;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import nl.math4all.mathunited.configuration.Configuration;
import nl.math4all.mathunited.configuration.UserSettings;
import nl.math4all.mathunited.configuration.Users;
import nl.math4all.mathunited.exceptions.*;
import java.io.*;
import java.net.*;

import java.util.Properties;
import javax.mail.AuthenticationFailedException;
import javax.mail.Authenticator;
import javax.mail.PasswordAuthentication;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.*;
import javax.servlet.http.*;
/**
 *
 * @author martijnslob
 */
public class UserManager {
    
    public static UserSettings checkCredentials(String name, String password) throws LoginException, ConfigException {
        Users users = Users.getInstance();
        Map<String, UserSettings> userMap = users.getUsers();
        UserSettings usettings = userMap.get(name);
        if(usettings==null) {
            throw new LoginException("Unknown username");
        }

        String passwordEncr = hash(password + (""+usettings.salt));

        if(!passwordEncr.equals(usettings.password)) {
            throw new LoginException("Password is incorrect");
        }
        return usettings;
    }
    
    //check if user is logged in
    public static UserSettings isLoggedIn(HttpServletRequest request, HttpServletResponse response)  throws LoginException, ConfigException {
        try{
            Configuration config = Configuration.getInstance();
            String userName=null, userAgent=null;
            Cookie[] cookieArr = request.getCookies();
            if(cookieArr != null) {
                for(Cookie c:cookieArr) {
                    String name = c.getName();
                    if(name.equals("USERID")) {
                        userName = c.getValue();
                    }
                    if(name.equals("USERAGENT")) {
                        userAgent = c.getValue();
                    }
                }
            }
            if(userName==null || userAgent==null) {
                throw new LoginException("Not logged in.");
            } 

            UserSettings usettings = Users.getInstance().getUsers().get(userName);
            if(usettings==null) {
                throw new LoginException("Login error: unknown user "+userName);
            }
            if(!userAgent.equals(hash(request.getHeader("User-Agent")))){
                Cookie cookie = new Cookie("USERID", userName);
                cookie.setMaxAge(0);
                response.addCookie(cookie);
                cookie = new Cookie("USERAGENT", "dummy");
                cookie.setMaxAge(0);
                response.addCookie(cookie);

                throw new LoginException("Login error: this is not the same computer on which you logged in!");
            }
            //valid login
            Cookie cookie = new Cookie("USERID", userName);
            cookie.setMaxAge(24*60*3);
            response.addCookie(cookie);

            return usettings;
        } catch(LoginException e) {
            //clear cookies
            Cookie[] cookieArr = request.getCookies();
            if(cookieArr != null) {
                for(Cookie c:cookieArr) {
                    String name = c.getName();
                    if(name.equals("USERID")) {
                        c.setMaxAge(0);
                        response.addCookie(c);
                    }
                    if(name.equals("USERAGENT")) {
                        c.setMaxAge(0);
                        response.addCookie(c);
                    }
                    if(name.equals("REPO")) {
                        c.setMaxAge(0);
                        response.addCookie(c);
                    }
                }
            }
            throw(e);
        }
    }
    
    public static UserSettings resetPassword(String userId) throws Exception {
        Users users = Users.getInstance();
        UserSettings usettings = users.getUsers().get(userId);
        if(usettings==null) {
            throw new LoginException("Login error: unknown user "+userId);
        }

        Long code = Math.round(Math.random()*1e5);
        String password = code.toString();
        usettings.password = hash(password + (""+usettings.salt));
        users.save();
        sendMail("Nieuw wachtwoord","Uw wachtwoord is nu: "+password, usettings.mail);
        return usettings;
    }
    
    //uses MD5
    public static String hash(String md5) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
            byte[] array = md.digest(md5.getBytes());
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < array.length; ++i) {
                sb.append(Integer.toHexString((array[i] & 0xFF) | 0x100).substring(1,3));
            }
            return sb.toString();
        } catch (java.security.NoSuchAlgorithmException e) { }
        return null;
    }

    private static void sendMail(String subject, String txt, String address) throws Exception {
        Configuration config = Configuration.getInstance();
        Properties props = new Properties();
        props.setProperty("mail.host", config.mail_host);
        props.setProperty("mail.smtp.port", config.mail_smtp_port);
        props.setProperty("mail.smtp.auth", "true");
        props.setProperty("mail.smtp.starttls.enable", "true");

        Authenticator auth = new SMTPAuthenticator(config.mail_username, config.mail_password);

        Session session = Session.getInstance(props, auth);

        MimeMessage msg = new MimeMessage(session);
        msg.setText(txt);
        msg.setSubject(subject);
        msg.setFrom(new InternetAddress(config.admin_mail));
        msg.addRecipient(Message.RecipientType.TO, new InternetAddress(address));
        Transport.send(msg);
    }

    private static class SMTPAuthenticator extends Authenticator {
        private PasswordAuthentication authentication;

        public SMTPAuthenticator(String login, String password) {
            authentication = new PasswordAuthentication(login, password);
        }

        @Override
        protected PasswordAuthentication getPasswordAuthentication() {
            return authentication;
        }
    }
}
