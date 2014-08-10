<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.lang.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="mathunited.configuration.*" %>
<%@ page import="mathunited.model.*" %>
<%@ page import="mathunited.utils.*" %>
<html>
<head>
	<link rel="stylesheet" href="css/basis_studiovo.css?v=1" type="text/css"/>
    <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js"></script>
    <script type="text/javascript" src="javascript/MathUnited_studiovo.js"></script>
</head>
<body class="backend-page">
<% try { %>
<%
	Configuration myconfig = Configuration.getInstance(application);

    Map<String, String[]> paramMap = request.getParameterMap();
    Map<String, String> parameterMap = new HashMap<String, String>();
    for(Map.Entry<String, String[]> entry : paramMap.entrySet()) {
        String pname = entry.getKey();
        String[] pvalArr = entry.getValue();
        if(pvalArr!=null && pvalArr.length>0) {
           parameterMap.put(pname, pvalArr[0]);
        }
    }
    String repo = parameterMap.get("repo");
   	if(repo==null)
   		throw new Exception("Het verplichte argument 'repo' ontbreekt: "+repo);
    Repository repository = myconfig.getRepos().get(repo);
    if(repository==null) {
        throw new Exception("Onbekende repository: "+repo);
    }

	String threadid = request.getParameter("threadid");
   	if(threadid==null || threadid.isEmpty())
   		throw new Exception("Het verplichte argument 'threadid' ontbreekt");

	String logintoken = parameterMap.get("logintoken");
   	if(logintoken==null || logintoken.isEmpty())
   		throw new Exception("Het verplichte argument 'logintoken' ontbreekt");
    String userid = Utils.userIdFromLoginToken(logintoken);
    User user = User.load(userid, repository);
    
    if (user == null || !user.isRegistered())
    	response.sendRedirect("/registeruser.jsp?logintoken=" + URLEncoder.encode(logintoken, "UTF-8") + "&repo=" + repo + "&threadid=" + threadid);
    	
    ClassList classes;
    if (user.isTeacher())
    	classes = ClassList.load(user.id, repository);
    else
    	classes = ClassList.loadForStudent(user.id, repository);

%>

<h3>Mijn profiel</h3>

<table>
	<tr><td>Naam:</td><td><%= user.fullName() %></td></tr>
	<tr><td>E-mail:</td><td><%= user.email %></td></tr>
</table>

<br/>

<a href="registeruser.jsp?logintoken=<%= URLEncoder.encode(logintoken, "UTF-8") %>&repo=<%= repo %>&threadid=<%= threadid %>" class="popup-label">Aanpassen</a>

<br/>

<h3>Mijn klassen</h3>

<% if (request.getParameter("added") != null) { %>
	<% if (user.isTeacher()) { %>
		<div class="message">Klas succesvol toegevoegd!</div>
	<% } else { %>
		<div class="message">Je bent succesvol aan de klas toegevoegd!</div>
	<% } %>
<% } %>

<% if (classes.items.size() > 0) { %>

<table class="grid">
	<tr>
		<th>Naam klas</th><th>
		<% if (user.isTeacher()) { %>
			Aantal leerlingen
		<% } else { %>
			Leraar
		<% } %>
		</th>
		<th>Opties</th>
	</tr>
<%
   	for (mathunited.model.Class cls : classes.items) {
   		User teacher = User.load(cls.ownerId, repository);
   		StudentList students = StudentList.loadForClass(cls.id, repository);
%>
	<tr><td>
		<% if (user.isTeacher()) { %>
			<a href="viewclassresult.jsp?repo=<%= repo %>&threadid=<%= threadid %>&logintoken=<%= URLEncoder.encode(logintoken, "UTF-8") %>&classid=<%= cls.id %>"><%= cls.id %></a>
		<% } else { %>
			<%= cls.id %>
		<% } %>
	</td>
	<% if (user.isTeacher()) { %>
		<td style="text-align: right"><%= students.items.size() %></td>
	<% } else { %>
		<td><%= teacher.fullName() %></td>
	<% } %>
	<td>
		<% if (user.isTeacher()) { %>
		<a href="deleteclass.jsp?id=<%= cls.id %>&repo=<%= repo %>&threadid=<%= threadid %>&logintoken=<%= URLEncoder.encode(logintoken, "UTF-8") %>" onclick="return confirm('Weet je zeker dat de klas <%= cls.id %> wilt verwijderen?')">Verwijderen</a></td>
		<% } else { %>
		<a href="unregisterclass.jsp?id=<%= cls.id %>&repo=<%= repo %>&threadid=<%= threadid %>&logintoken=<%= URLEncoder.encode(logintoken, "UTF-8") %>" onclick="return confirm('Weet je zeker dat je je voor klas <%= cls.id %> wilt afmelden?')">Afmelden</a></td>
		<% } %>
	</tr>
<%
	}
%>
</table>

<% } else { %>
	<% if (user.isTeacher()) { %>
		<div class="empty-text">Je hebt nog geen klassen aangemaakt</div>
	<% } else { %>
		<div class="empty-text">Je bent nog bij geen enkele klas aangemeld</div>
	<% } %>
<% } %>

<br />

<% if (user.isTeacher()) { %>
<a href="addclass.jsp?logintoken=<%= URLEncoder.encode(logintoken, "UTF-8") %>&repo=<%= repo %>&threadid=<%= threadid %>" class="popup-label">Klas toevoegen</a>
<% } else { %>
<a href="registerforclass.jsp?logintoken=<%= URLEncoder.encode(logintoken, "UTF-8") %>&repo=<%= repo %>&threadid=<%= threadid %>" class="popup-label">Aanmelden voor nieuwe klas</a>
<% } %>

<% } catch(Exception e) { %><%= Utils.renderErrorHtml(e) %><% } %>

<%-- 
<p>key = <%= Utils.generateKey() %></p>
<p>
encoded = <%= Utils.encodeData("dnote|affiliate|ENTREE") %><br/>
decoded = <%= Utils.decodeData("wXfLxhpVClrS3ZhQ1rT8Nx4KT7Cn00bB55+tfpgKX/4=") %>
</p>
--%>
</body>
</html>
