<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.lang.*" %>
<%@ page import="java.util.*" %>
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

    String userid = parameterMap.get("userid"); 
   	if(userid==null || userid.isEmpty())
   		throw new Exception("Het verplichte argument 'userid' ontbreekt");
    User user = User.load(userid, repository);
    
    if (user == null || !user.isRegistered())
    	response.sendRedirect("/registeruser.html?userid=" + userid + "&repo=" + repo + "&threadid=" + threadid);
    	
    ClassList classes;
    if (user.isTeacher())
    	classes = ClassList.load(user.id, repository);
    else
    	classes = ClassList.loadForStudent(user.id, repository);

%>

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
	</tr>
<%
   	for (mathunited.model.Class cls : classes.items) {
   		User teacher = User.load(cls.ownerId, repository);
   		StudentList students = StudentList.loadForClass(cls.id, repository);
%>
	<tr><td>
		<% if (user.isTeacher()) { %>
			<a href="viewclassresult.jsp?repo=<%= repo %>&threadid=<%= threadid %>&userid=<%= userid %>&classid=<%= cls.id %>"><%= cls.id %></a>
		<% } else { %>
			<%= cls.id %>
		<% } %>
	</td>
	<% if (user.isTeacher()) { %>
		<td style="text-align: right"><%= students.items.size() %></td>
	<% } else { %>
		<td><%= teacher.fullName() %></td>
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
<a href="addclass.jsp?userid=<%= user.id %>&repo=<%= repo %>&threadid=<%= threadid %>" class="popup-label">Klas toevoegen</a>
<% } else { %>
<a href="registerforclass.jsp?userid=<%= user.id %>&repo=<%= repo %>&threadid=<%= threadid %>" class="popup-label">Aanmelden voor nieuwe klas</a>
<% } %>

<% } catch(Exception e) { %><%= Utils.renderErrorHtml(e) %><% } %>

<!--
<p>
encoded = <%= Utils.encodeData("dnote|affiliate|ENTREE") %><br/>
decoded = <%= Utils.decodeData("wXfLxhpVClrS3ZhQ1rT8N4W3r+ImIk/SdXR3JMCz158=") %>
</p>
-->
</body>
</html>
