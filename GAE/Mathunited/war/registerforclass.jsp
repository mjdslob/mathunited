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
<head>
	<link rel="stylesheet" href="css/basis_studiovo.css?v=1" type="text/css"/>
    <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js"></script>
    <script type="text/javascript" src="javascript/MathUnited_studiovo.js"></script>
    <script type="text/javascript">
	function submit()
	{
		if ($('#selectedTeacherId').val() == "") { alert("Voer a.u.b. een leraar in"); return; }
		if ($('#selectedClassId').val() == "") { alert("Voer a.u.b. een klas in"); return; }
		document.getElementById('form').submit();
	}
	function submitWithoutValidation()
	{
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

    String logintoken = request.getParameter("logintoken");
   	if(logintoken==null || logintoken.isEmpty())
   		throw new Exception("Het verplichte argument 'logintoken' ontbreekt");
    String userid = Utils.userIdFromLoginToken(logintoken);
    User user = User.load(userid, repository);
    
    if (user == null || !user.isRegistered())
    	response.sendRedirect("/registeruser.jsp?logintoken=" + URLEncoder.encode(logintoken, "UTF-8") + "&repo=" + repo + "&threadid=" + threadid);
    	
    if (user.isTeacher())
    	throw new UserException("Je kunt je als leraar niet aanmelden voor klassen.");
    
   	UserList teachers = UserList.loadTeachers(user.schoolcode, repository);

	// get the list of classes already registered to, this will be used later to filter the list of possible classes that still can be registered to
	ClassList registeredClasses = ClassList.loadForStudent(userid, repository);
   	
   	String selectedTeacherId = null;
   	String selectedClassId = null;
   	ClassList classes = null;
   	if (request.getParameter("postback") != null)
	{
		selectedTeacherId = request.getParameter("selectedTeacherId");
		selectedClassId = request.getParameter("selectedClassId");
    	classes = ClassList.load(selectedTeacherId, repository);
    	
    	if (selectedClassId != null && !selectedClassId.equals(""))
    	{    	
    		Student student = new Student();
    		student.userId = userid;
    		student.classId = selectedClassId;
    		student.save(repository);

	    	response.sendRedirect("/viewclasses.jsp?logintoken=" + URLEncoder.encode(logintoken, "UTF-8") + "&repo=" + repo + "&threadid=" + threadid + "&added=" + selectedClassId);
    	}
	}
%>

<h3>Mijn klassen - Aanmelden voor klas</h3>

<form method="post" action="/registerforclass.jsp?logintoken=<%= URLEncoder.encode(logintoken, "UTF-8") %>&repo=<%= repo %>&threadid=<%= threadid %>" id="form">
	<input type="hidden" id="postback" name="postback" value="1" />
	<table>
		<tr>
			<td>Leraar*:</td>
			<td>
				<select id="selectedTeacherId" name="selectedTeacherId" onchange="submitWithoutValidation()">
				<option value="">Kies een leraar...</option>
				<% for (User teacher : teachers.items)  { %>
				<option value="<%= teacher.id %>" <% if (teacher.id.equals(selectedTeacherId)) { %>selected="selected"<% } %>><%= teacher.fullName() %></option>
				<% } %>
				</select>
			</td>
		</tr>
		<tr>
			<td>Klas*:</td>
			<td>
				<% if (classes != null) { %>
					<% if (classes.items.size() == 0) { %>
						<div class="empty-text">Deze leraar heeft nog geen klassen aangemaakt</div>
					<% } else { %>
						<% boolean canChoose = false; %>
						<select id="selectedClassId" name="selectedClassId">
							<option value="">Kies een klas...</option>
							<% for (Class cls : classes.items)  { %>
								<% if (registeredClasses.byId(cls.id) == null) { %>
									<% canChoose = true; %>
									<option value="<%= cls.id %>" <% if (cls.id.equals(selectedClassId)) { %>selected="selected"<% } %>><%= cls.id %></option>
								<% } %>
							<% } %>
						</select>
						<% if (!canChoose) { %>
							<div class="empty-text">Je bent reeds bij alle klassen van deze leraar aangemeld</div>
						<% } %>
					<% } %>
				<% } %>
			</td>
		</tr>
	</table>
	<small>Velden met een * zijn verplicht</small><br />
	<a href="javascript:{}" onclick="submit()" class="popup-label">Aanmelden</a>
</form>

<% } catch(Exception e) { %><%= Utils.renderErrorHtml(e) %><% } %>
</body>
</html>
