<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.lang.*" %>
<%@ page import="java.util.*" %>
<%@ page import="mathunited.configuration.*" %>
<%@ page import="mathunited.model.*" %>
<%@ page import="mathunited.model.Class" %>
<%@ page import="mathunited.utils.*" %>
<html>
<head>
	<link rel="stylesheet" href="css/basis_studiovo.css?v=1" type="text/css"/>
    <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js"></script>
    <script type="text/javascript" src="javascript/MathUnited_studiovo.js"></script>
    <script type="text/javascript">
	function submit()
	{
		if ($('#classId').val() == "") { alert("Voer a.u.b. de naam van de klas in"); return; }
		document.getElementById('form').submit();
	}
    </script>
</head>
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

    String userid = request.getParameter("userid");
   	if(userid==null || userid.isEmpty())
   		throw new Exception("Het verplichte argument 'userid' ontbreekt");
    User user = User.load(userid, repository);
    
    if (user == null || !user.isRegistered())
    	response.sendRedirect("/registeruser.html?userid=" + userid + "&repo=" + repo + "&threadid=" + threadid);
    	
    if (!user.isTeacher())
    	throw new UserException("Je bent niet bevoegd klassen aan te maken.");
    	
    if (request.getParameter("postback") != null) {
	    String classId = request.getParameter("classId");
	   	if(classId==null)
	   		throw new Exception("Het verplichte argument 'classId' ontbreekt");
	   	
	   	Class cls = Class.load(classId, repository);
	   	if (cls != null) {
	   		if (cls.ownerId.equals(userid))
	   			throw new UserException("Je hebt al een klas toegevoegd onder deze naam. Voer een andere naam in of gebruik de bestaande klas.");
   			else
	   			throw new UserException("Een klas met deze naam bestaat reeds in het systeem. Voer een andere naam in.");
	   	}
	   	cls = new Class();
	   	cls.id = classId;
	   	cls.ownerId = userid;
	   	cls.save(repository);
	   	
    	response.sendRedirect("/viewclasses.jsp?userid=" + userid + "&repo=" + repo + "&threadid=" + threadid + "&added=" + classId);
    }
   
%>

<h3>Mijn klassen - Klas aanmaken</h3>

<form method="post" action="/addclass.jsp?userid=<%= user.id %>&repo=<%= repo %>&threadid=<%= threadid %>" id="form">
	<input type="hidden" id="postback" name="postback" value="1" />
	<table>
		<tr>
			<td>Naam klas*:</td><td><input name="classId" id="classId" />
		</tr>
	</table>
	<small>Velden met een * zijn verplicht</small><br />
	<a href="javascript:{}" onclick="submit()" class="popup-label">Toevoegen</a>
	<a href="/viewclasses.jsp?userid=<%= user.id %>&repo=<%= repo %>&threadid=<%= threadid %>">annuleren</a>
</form>

<% } catch(Exception e) { %><%= Utils.renderErrorHtml(e) %><% } %>
</body>
</html>
