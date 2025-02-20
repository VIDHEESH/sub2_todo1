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
    <%
    ToDoDAOIntf dao = ToDoDAOimpl.getInstance();
    int regid = 0;
    String fname = "";
    List<Task> taskList = null;
    
    try {
      if(session.getAttribute("regid") != null) {
        regid = Integer.parseInt(session.getAttribute("regid").toString());
        fname = dao.getFnameByRegId(regid);
        // Get tasks in the same try block to handle exceptions together
        taskList = dao.findAllTasksByRegId(regid);
    %>
      <%=fname%>
      <a href="./LogoutServlet">Logout</a>
    <%
      } else {
        response.sendRedirect("Login.jsp");
        return; // Important to prevent further execution
      }
    } catch (Exception e) {
      // Log the exception - use application log instead of System.err
      application.log("Database error in ViewTasks.jsp: " + e.getMessage());
    %>
      <div style="color:red">Database connection error. Please try again later.</div>
    <%
      taskList = java.util.Collections.emptyList(); // Use empty list to avoid NullPointerException
    }
    %>
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
 
  <table align="center" width="50%" border="1">
    <tr>
      <th>TaskID</th>
      <th>TaskName</th>
      <th>TaskDate</th>
      <th>TaskStatus</th>
      <th></th>
    </tr>
    <%
      if(taskList != null && !taskList.isEmpty()) {
        for(Task task:taskList) {
          int taskId=task.getTaskId();
          String taskName=task.getTaskName();
          String taskDate=task.getTaskDate();
          int taskStatus=task.getTaskStatus();
          
          if(taskStatus==3) {
    %>
    <tr style="text-decoration:line-through;">
        <td><%=taskId%></td>
        <td><%=taskName%></td>
        <td><%=taskDate%></td>
        <td>Completed</td>
        <td></td>
    </tr>       
    <%
          } else {
            String statusText = taskStatus == 1 ? "Not Started" : "In Progress";
    %>
    <tr>
        <td><%=taskId%></td>
        <td><%=taskName%></td>
        <td><%=taskDate%></td>
        <td><%=statusText%></td>
        <td><a href="./MarkTaskCompletedServlet?regid=<%=regid%>&taskId=<%=taskId%>">Complete</a></td>
    </tr>
    <%   
          }
        }
      } else {
    %>
    <tr>
      <td colspan="5" align="center">No tasks found or unable to retrieve tasks</td>
    </tr>
    <%
      }
    %>
  </table>
</body>
</html>