<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
<!-- meta HTTP-EQUIV="REFRESH" content="0;
url=http://www.mathunited.nl/wiskundemenu/WM_overview.html"-->
</head>
<body><h3>redirect...</h3>
<% 
if (request.getServerName().toLowerCase().equals("themas.studioaardrijkskunde.nl")) 
	response.sendRedirect("http://www.studioaardrijkskunde.nl");
else if (request.getServerName().toLowerCase().equals("themas.studiobiologie.nl")) 
	response.sendRedirect("http://www.studiobiologie.nl");
else if (request.getServerName().toLowerCase().equals("themas.studiogeschiedenis.nl")) 
	response.sendRedirect("http://www.studiogeschiedenis.nl");
else if (request.getServerName().toLowerCase().equals("themas.studionederlands.nl")) 
	response.sendRedirect("http://www.studionederlands.nl");
else if (request.getServerName().toLowerCase().equals("themas.studioeconomie.nl")) 
	response.sendRedirect("http://www.studioeconomie.nl");
else if (request.getServerName().toLowerCase().equals("themas.studiomenm.nl")) 
	response.sendRedirect("http://www.studiomenm.nl");
else if (request.getServerName().toLowerCase().equals("themas.studiowiskunde.nl")) 
	response.sendRedirect("http://www.studiowiskunde.nl");
else 
	response.sendRedirect("http://www.mathunited.nl/wiskundemenu/WM_overview.html");
%>
</body></html>
