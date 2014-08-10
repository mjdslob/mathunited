<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="mathunited.configuration.*" %>
<%@ page import="mathunited.model.*" %>
<%@ page import="mathunited.utils.*" %>
<html>
<head>
	<link rel="stylesheet" href="css/basis_studiovo.css?v=1" type="text/css"/>
    <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js"></script>
    <script type="text/javascript" src="javascript/MathUnited_studiovo.js"></script>
	<script type="text/javascript">
	function IsEmail(email) {
	  var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
	  return regex.test(email);
	}

	function submit()
	{
		if ($('#firstName').val() == "") { alert("Voer a.u.b. je voornaam in"); return; }
		if ($('#lastName').val() == "") { alert("Voer a.u.b. je achternaam in"); return; }
		if ($('#email').val() != "" && !IsEmail($('#email').val())) { alert("Het e-mailadres is ongeldig"); return; }
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
	User user = null;
	String logintoken = request.getParameter("logintoken");
    String userid = Utils.userIdFromLoginToken(logintoken);
    String userrole = Utils.userRoleFromLoginToken(logintoken);
   	String schoolcode = Utils.userSchoolFromLoginToken(logintoken); // optional when already registered
    if (userid != null && userid.length() > 0)
		user = User.load(userid, repository);
	if (user == null)
		user = new User();
%>

<% if (user.isRegistered()) { %>
	<h1>Profiel bewerken</h1>
<% } else { %>
	<h1>Registratie</h1>
	<p>Dit is de eerste keer dat je je aanmeldt in ons systeem. We vragen je daarom wat gegevens in te vullen zodat we je beter van dienst kunnen zijn.</p>
<% } %>
	<form method="post" action="/viewresult?post=registeruser" id="form">
		<input type="hidden" id="logintoken" name="logintoken" value="<%= logintoken %>">
		<input type="hidden" id="repo" name="repo">
		<input type="hidden" id="threadid" name="threadid">
		<script type="text/javascript">
		$("#repo").val(getURLParameter("repo"));
		$("#threadid").val(getURLParameter("threadid"));
		</script>
		<table>
			<tr>
				<td>Je voornaam*:</td><td><input id="firstName" name="firstName" value="<%= user.firstName == null ? "" : user.firstName %>" /></td>
			</tr>
			<tr>
				<td>Tussenvoegsel:</td><td><input id="lastNamePrefix" name="lastNamePrefix" value="<%= user.lastNamePrefix == null ? "" : user.lastNamePrefix %>" /></td>
			</tr>
			<tr>
				<td>Achternaam*:</td><td><input id="lastName" name="lastName" value="<%= user.lastName == null ? "" : user.lastName %>" /></td>
			</tr>
			<tr>
				<td>E-mail:</td><td><input id="email" name="email" value="<%= user.email == null ? "" : user.email %>" /></td>
			</tr>
		</table>
		<small>Velden met een * zijn verplicht</small><br />
		<a href="javascript:{}" onclick="submit()" class="popup-label"><% if (user.isRegistered()) { %>Opslaan<% } else { %>Registreren<% } %></a>
	</form>
<% } catch(Exception e) { %><%= Utils.renderErrorHtml(e) %><% } %>
</body>
</html>
