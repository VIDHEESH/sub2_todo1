<%@page import="beans.Task"%>
<%@page import="java.util.List"%>
<%@page import="dao.ToDoDAOimpl"%>
<%@page import="dao.ToDoDAOIntf"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>View Tasks</title>
</head>
<body>
 
  <p align="right" style="background-color:'light grey';">
    Welcome
    <%
      ToDoDAOIntf dao=ToDoDAOimpl.getInstance();
      int regId=Integer.parseInt(session.getAttribute("regId").toString());
      String fname=dao.getFnameByRegId(regId);
    %>
    <%=fname%>,
    <a href="./LogoutServlet">Logout</a>
  </p>
 
  <form method="post" action="./AddTaskServlet">
    <table border="1" align="center" width="15%">
      <tr>
        <th>Task Name</th>
        <td><input type="text" name="taskName"></td>
      </tr>
      <tr>
        <th>Task Date</th>
        <td><input type="text" name="taskDate" placeholder="dd-mm-yyyy"></td>
      </tr>
      <tr>
        <th>Task Status</th>
        <td>
          <select name="taskStatus">
            <option value="1">Not Yet Started</option>
            <option value="2">In Progress</option>
            <option value="3">Completed</option>
          </select>
        </td>
      </tr>
      <tr>
        <th><input type="submit" name="submit" value="Add Task"></th>
        <td><input type="reset" name="reset" value="Clear"></td>
      </tr>
    </table>
  </form>
 
  <hr width="100%" color="black" />
 
  <%
    List<Task> taskList=dao.findAllTasksByRegId(regId);
  %>
  <table align="center" width="50%" border="1">
    <tr>
      <th>TaskID</th>
      <th>TaskName</th>
      <th>TaskDate</th>
      <th>TaskStatus</th>
      <th></th>
    </tr>
    <%
      for(Task task:taskList) {
        int taskId=task.getTaskId();
        String taskName=task.getTaskName();
        String taskDate=task.getTaskDate();
        int taskStatus=task.getTaskStatus();
    %>
    <%
      if(taskStatus==3) {
    %>
    <tr style="text-decoration:line-through;">
        <td><%=taskId%></td>
        <td><%=taskName%></td>
        <td><%=taskDate%></td>
        <td><%=taskStatus%></td>
        <td>Completed</td>
    </tr>       
    <%
      } else {
    %>
    <tr>
        <td><%=taskId%></td>
        <td><%=taskName%></td>
        <td><%=taskDate%></td>
        <td><%=taskStatus%></td>
        <td><a href="./MarkTaskCompletedServlet?regId=<%=regId%>&taskId=<%=taskId%>">Complete</a></td>
    </tr>
    <%   
      }
    %>
    <%
    }
    %>
  </table>
</body>
</html>