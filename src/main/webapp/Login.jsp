<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Insert title here</title>
</head>
<body>
	<form method="post" action="./LoginServlet">
		<table border="1" align="center" width="16%">
			<tr>
				<th>Email</th>
				<td><input type="text" name="email"></td>
			</tr>
			<tr>
				<th>Pass</th>
				<td><input type="password" name="pass"></td>
			</tr>
			<tr>
				<th><input type="submit" name="submit" value="Login"></th>
				<td><input type="reset" name="reset" value="Clear"></td>
			</tr>
		</table>
	</form>
	<p align="center">New User, 
			<a href="Register.html">SignUp</a></p>
	<%
		Object o=request.getAttribute("loginError");
	%>
	<p align="center" 
	style="background-color:yellow;color:red;font-style:italic;">
	<%=(o==null)?"":o.toString()%>
	</p>
</body>
</html>