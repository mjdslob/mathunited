<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.lang.*" %>
<%@ page import="java.util.*" %>
<%@ page import="mathunited.configuration.*" %>
<%@ page import="mathunited.model.*" %>
<%@ page import="mathunited.model.Class" %>
<%@ page import="mathunited.utils.*" %>
<%@ page import="org.w3c.dom.Document" %>
<html>
<head>
	<link rel="stylesheet" href="css/basis_studiovo.css?v=6" type="text/css"/>
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
    	
    String classid = parameterMap.get("classid"); 
   	if(classid==null || classid.isEmpty())
   		throw new Exception("Het verplichte argument 'classid' ontbreekt");

	boolean studentremoved = false;
	String removeid = request.getParameter("removeid");
	if (removeid != null) {
		if (Student.delete(removeid, classid, repository))
			studentremoved = true;
	}

    Class cls = Class.load(classid, repository);
    StudentList students = StudentList.loadForClass(classid, repository);
    
    org.w3c.dom.Document inputDoc = Utils.getResultStrucureXml(repository, "result-structure/" + threadid);
    
	HashMap<Integer, Integer> eindExamenSiteItems = Utils.getEindExamenSiteItems(inputDoc);
	
    HashMap<String, Map<Integer, Score>> results = new HashMap<String, Map<Integer, Score>>();
	Utils.getEindExamenSiteResults(eindExamenSiteItems, students, results);
%>

<% if (studentremoved) { %>
	<div class="message">Leerling succesvol verwijderd uit de klas!</div>
<% } %>

<h3>Voortgang <%= cls.id %></h3>

<% if (results.size() > 0) { %>

<table class="grid class-result">
<% 
	boolean first = true;
    for (Map.Entry<String, Map<Integer, Score>> entry : results.entrySet()) {
    	User student = User.load(entry.getKey(), repository);
    	Map<Integer, Score> assignments = entry.getValue();
		ScoreGroup result = Utils.transformResultsTree(inputDoc, assignments);
%>
<% if (first) { %>
	<tr>
		<th class="first">&nbsp;</th>
<%
    for (ScoreGroup group : result.groups) {
%>
		<th>
			<%= group.title %>
		</th>
<%
    }
%>
		<th class="last">&nbsp;</th>
	</tr>
<%
	first = false; 
} 
%>
	<tr>
		<td class="clickable">
			<a href="/viewresult?repo=<%= repo %>&threadid=<%= threadid %>&userid=<%= userid %>&viewid=<%= student.id %>"><%= student.fullName() %> ></a>
		</td>
<%
    for (ScoreGroup group : result.groups) {
%>
		<td>
			<%= Math.round((float)group.score * 100.0f / (float)group.total) %>%
		</td>
<%
    }
%>
		<td class="clickable">
			<a href="/viewclassresult.jsp?repo=<%= repo %>&threadid=<%= threadid %>&userid=<%= userid %>&classid=<%= cls.id %>&removeid=<%= student.id %>" onclick="return confirm('Weet je zeker dat je deze leerling uit de klas wil verwijderen?')">Verwijder</a>
		</td>
	</tr>
<%
    }
%>
</table>

<% } else { %>
	<div class="empty-text">Er hebben zich nog geen leerlingen aangemeld bij deze klas</div>
<% } %>


<% } catch(Exception e) { %><%= Utils.renderErrorHtml(e) %><% } %>
</body>
</html>
