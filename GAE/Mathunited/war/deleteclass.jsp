<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.lang.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="mathunited.configuration.*" %>
<%@ page import="mathunited.model.*" %>
<%@ page import="mathunited.model.Class" %>
<%@ page import="mathunited.model.User.UserRole" %>
<%@ page import="mathunited.utils.*" %>
<html>
<body class="backend-page">
<% try { %>
<%
	Configuration myconfig = Configuration.getInstance(application);

    String repo = request.getParameter("repo");
   	if(repo==null)
   		throw new Exception("Het verplichte argument 'repo' ontbreekt: "+repo);
    Repository repository = myconfig.getRepos().get(repo);
    if(repository==null) {
        throw new Exception("Onbekende repository: "+repo);
    }

	String threadid = request.getParameter("threadid");
   	if(threadid==null || threadid.isEmpty())
   		throw new Exception("Het verplichte argument 'threadid' ontbreekt");

    String logintoken = request.getParameter("logintoken");
   	if(logintoken==null || logintoken.isEmpty())
   		throw new Exception("Het verplichte argument 'logintoken' ontbreekt");
    String userid = Utils.userIdFromLoginToken(logintoken);
    User user = User.load(userid, repository);
    
    String id = request.getParameter("id");
   	if(id==null || id.isEmpty())
   		throw new Exception("Het verplichte argument 'id' ontbreekt");
   	Class cls = Class.load(id, repository);

	if (!cls.ownerId.equals(userid))
   		throw new Exception("Je bent niet gemachtigd deze klas te verwijderen");
   	
	StudentList students = StudentList.loadForClass(id, repository);
   	for (Student student : students.items) {
   		student.delete(repository);
   	}
   	
   	cls.delete(repository);   	

   	response.sendRedirect("/viewclasses.jsp?logintoken=" + URLEncoder.encode(logintoken, "UTF-8") + "&repo=" + repo + "&threadid=" + threadid);
%>
<% } catch(Exception e) { %><%= Utils.renderErrorHtml(e) %><% } %>
</body>
</html>
