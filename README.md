# sub2_todo1

1) 
	a) To download MySQL database, please download XAMPP software from internet and install it.
	b) please download mysql-connector-j-8.2.0.jar file also from internet.

2) Setting up CLASSPATH setting for Oracle/MySQL JDBC driver
Press Win icon-> env-> select "The System Environment Variables" link-> click on Environemt Variables button-> In the system variables-> If CLASSPATH is no there-> click on New button-> 
Variable Name: CLASSPATH 
Variable Value: .;D:\Softwares\mysql-connector-j-8.2.0\mysql-connector-j-8.2.0.jar;C:\oraclexe\app\oracle\product\10.2.0\server\jdbc\lib\ojdbc14.jar
click on all OK buttons

PATH
C:\Program Files\Java\jdk1.8.0_202\bin

3) Verifying CLASSPATH setting
open command prompt
C:\> javap com.mysql.jdbc.Driver
C:\> javap oracle.jdbc.driver.OracleDriver

// Write a JDBC program to connect to Oracle/MySQL DB
// JDBC_Conn_1.java
import java.sql.*;
class JDBC_Conn_1 {
	public static void main(String rags[]) throws Exception {		
		Class.forName("com.mysql.jdbc.Driver");

		Connection con=DriverManager.getConnection("jdbc:mysql://localhost:3306/sub2", "root", "");
		
		System.out.println(con);	
	}
}

		// for oracle
		// Class.forName("oracle.jdbc.driver.OracleDriver");
		// for oracle
		// Connection con=DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:XE", "sub2", "sub2");

table creations
inserting record into register table using Statement
inserting record into register table using PreparedStatement
accept username and pass from STDIN and verify them in register table, display Login Success, or Login Failed
insert record into tasks table using PreparedStatement
accept username and pass from STDIN, display the user corresponding all the tasks on STDOUT

table creations:
-----------------
login into Oracle DB, following are Oracle tables:
CREATE TABLE register (
	regid number, 	fname varchar2(20), lname varchar2(20),
	email varchar2(20), 	pass varchar2(20), mobile number(10), 	address varchar2(50),
	CONSTRAINT register_regid_pk PRIMARY KEY(regid)
);

create table tasks (
	taskid number, 	taskname varchar2(50), taskdate varchar2(10), 	
	taskstatus number CHECK (taskstatus IN (1,2,3)), regid NUMBER, 	CONSTRAINT tasks_taskid_pk PRIMARY KEY(taskid, regid), CONSTRAINT tasks_regid_fk FOREIGN KEY (regid) REFERENCES register(regid)
);

create table taskid_pks (
	regid NUMBER REFERENCES register(regid), taskid NUMBER );

login into MySQL DB, following are MySQL tables:
CREATE TABLE register (
	regid integer, 	fname varchar(20), lname varchar(20),
	email varchar(20), 	pass varchar(20), mobile integer, 	address varchar(50),
	CONSTRAINT register_regid_pk PRIMARY KEY(regid)
);

create table tasks (
	taskid integer, 	taskname varchar(50), taskdate varchar(10), 	
	taskstatus integer CHECK (taskstatus IN (1,2,3)), regid integer, 	CONSTRAINT tasks_taskid_pk PRIMARY KEY(taskid, regid), CONSTRAINT tasks_regid_fk FOREIGN KEY (regid) REFERENCES register(regid)
);

create table taskid_pks (
	regid integer REFERENCES register(regid), taskid integer);

Write one factory class to create and return DB connection to multiple users:
------------------------------------------------------------------------------------
// DBConn.java
import java.sql.*;
public class DBConn {
	static Connection con;
	public static Connection getConn() throws Exception {
		if(con==null) {
			Class.forName("oracle.jdbc.driver.OracleDriver");
			// Class.forName("com.mysql.jdbc.Driver");
			con=DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:XE", "sub2", "sub2");
			// con=DriverManager.getConnection("jdbc:mysql://localhost:3306/sub2", "root", "");
		}
		return con;
	}
}

inserting record into register table using Statement:
---------------------------------------------------------
// JDBC_Insert_2.java
import java.util.*;
import java.sql.*;
public class JDBC_Insert_2 {
	public static void main(String rags[]) throws Exception {
		Scanner sc=new Scanner(System.in);
		System.out.println("Enter FName");
		String fname=sc.nextLine();
		System.out.println("Enter LName");
		String lname=sc.nextLine();
		System.out.println("Enter Email");
		String email=sc.nextLine();
		System.out.println("Enter Pass");
		String pass=sc.nextLine();
		System.out.println("Enter Mobile");
		long mobile=sc.nextLong(); sc.nextLine();
		System.out.println("Enter Address");
		String address=sc.nextLine();
		
		Connection con=DBConn.getConn();
		Statement stmt=con.createStatement();
		// ResultSet executeQuery(String selectStmt)
		// int executeUpdate(String dmlStmt)
		
		// pk generation
		int regid=0;
		ResultSet rs=stmt.executeQuery("SELECT max(regid) FROM register");
		if(rs.next()) {
			regid=rs.getInt(1);
		}
		regid++;
		
		// record insertion
		int i=stmt.executeUpdate("INSERT INTO register VALUES ("+regid+",'"+fname+"','"+lname+"','"+email+"','"+pass+"',"+mobile+",'"+address+"')");
		
		if(i==1) 
			System.out.println("Record inserted");
		else 
			System.out.println("Insert failed");
		
		rs.close(); stmt.close(); con.close(); 
	}
}


---------------------------------------------------------
// inserting record into register table using PreparedStatement
// JDBC_Insert_3.java
import java.sql.*;
class JDBC_Insert_3 {
	public static void main(String rags[]) throws Exception {
		Connection con=DBConn.getConn();
		Statement stmt=con.createStatement();
		PreparedStatement pstmt=con.prepareStatement("INSERT INTO register VALUES (?,?,?,?,?,?,?)"); // ? is IN parameter/Placeholder
		
		String fname=rags[0];
		String lname=rags[1];
		String email=rags[2];
		String pass=rags[3];
		long mobile=Long.parseLong(rags[4]);
		String address=rags[5];
		
		// pk generation
		int regid=0;
		ResultSet rs=stmt.executeQuery("SELECT max(regid) rom register");
		if(rs.next()) {
			regid=rs.getInt(1);
		}
		regid++;
		
		// insert record into register table
		pstmt.setInt(1, regid);
		pstmt.setString(2, fname);
		pstmt.setString(3, lname);
		pstmt.setString(4, email);
		pstmt.setString(5, pass);
		pstmt.setLong(6, mobile);
		pstmt.setString(7, address);
		int i=pstmt.executeUpdate(); // i contains how many rows effected 
		if(i==1)
			System.out.println(i+" record inserted");
		
		rs.close(); pstmt.close(); stmt.close(); con.close();	
	}
}
javac JDBC_Insert_3.java
java JDBC_Insert_3 XYZ ABC xyz@gmail.com abc 9848012345 Dundigal

accept username and pass from STDIN and verify them in register table, display Login Success, or Login Failed:
--------------------------
// JDBC_Select_4.java
import java.sql.*;
import java.util.*;
public class JDBC_Select_4 {
	public static void main(String rags[]) throws Exception {
		Scanner sc=new Scanner(System.in);
		System.out.println("Enter Email");
		String email=sc.nextLine();
		System.out.println("Enter Pass");
		String pass=sc.nextLine();
		
		Connection con=DBConn.getConn();
		Statement stmt=con.createStatement();
		ResultSet rs=stmt.executeQuery("SELECT * FROM register WHERE email='"+email+"' AND pass='"+pass+"'");
		// if multiple records comes use while, if single record comes use if condition
		if(rs.next()) {
			System.out.println("Login Success");
		} else {
			System.out.println("Login Failed");
		}
		rs.close(); stmt.close(); con.close();
	}
}


insert record into tasks table using PreparedStatement:
-------------------------------------------------------------
// JDBC_Insert_5.java
import java.sql.*;
import java.util.*;
public class JDBC_Insert_5 {
	public static void main(String rags[]) throws Exception {
		Scanner sc=new Scanner(System.in);
		System.out.println("Enter Task Name");
		String taskName=sc.nextLine();
		System.out.println("Enter Task Date");
		String taskDate=sc.nextLine();
		System.out.println("Enter Task Status");
		int taskStatus=sc.nextInt();
		sc.nextLine();
		System.out.println("Enter Reg ID");
		int regID=sc.nextInt();
		sc.nextLine();
		
		Connection con=DBConn.getConn();
		Statement stmt=con.createStatement();
		PreparedStatement pstmt1=con.prepareStatement("INSERT INTO tasks VALUES (?,?,?,?,?)");
		PreparedStatement pstmt2=con.prepareStatement("INSERT INTO taskid_pks VALUES (?,?)");
		PreparedStatement pstmt3=con.prepareStatement("UPDATE taskid_pks SET taskid=? WHERE regid=?");
		
		int taskID=0; 
		boolean isNew=true;
		int i=0; 
		int j=0;
		
		// tx begins here
		con.setAutoCommit(false);
		ResultSet rs=stmt.executeQuery("SELECT taskid FROM taskid_pks WHERE regid="+regID);
		if(rs.next()) { // if task exist for that regid
			taskID=rs.getInt(1);
			isNew=false;
		}
		taskID++;
		
		pstmt1.setInt(1, taskID);
		pstmt1.setString(2, taskName);
		pstmt1.setString(3, taskDate);
		pstmt1.setInt(4, taskStatus);
		pstmt1.setInt(5, regID);
		i=pstmt1.executeUpdate();
		
		if(isNew==true) {
			pstmt2.setInt(1, regID);
			pstmt2.setInt(2, taskID);
			j=pstmt2.executeUpdate();
		} else {
			pstmt3.setInt(1, taskID);
			pstmt3.setInt(2, regID);
			j=pstmt3.executeUpdate();
		}
		
		if(i==1 && j==1) {
			con.commit();
			System.out.println("TX Success");
		} else {
			con.rollback();
			System.out.println("TX Failed");
		}
		
		rs.close(); stmt.close(); pstmt3.close(); pstmt2.close(); pstmt1.close(); con.close();
	}
}



accept username and pass from STDIN, display the user corresponding all the tasks on STDOUT:
--------------------------------------------------------------------------------------------------
// JDBC_Select_6.java
import java.sql.*;
public class JDBC_Select_6 {
	public static void main(String rags[]) throws Exception {
		if(rags.length!=2) {
			System.out.println("Pass Email and Pass as command line arguments");
		} else {
			String email=rags[0];
			String pass=rags[1];
			Connection con=DBConn.getConn();
			Statement stmt=con.createStatement();
			ResultSet rs=stmt.executeQuery("select * from tasks where regid=(select regid from register where email='"+email+"' and pass='"+pass+"')");
			while(rs.next()) {
				System.out.print(rs.getInt(1)+" ");
				System.out.print(rs.getString(2)+" ");
				System.out.print(rs.getString(3)+" ");
				System.out.println(rs.getInt(4));
			}
			rs.close(); stmt.close(); con.close();
		}
	}
}

java JDBC_Select_6 abc@gmail.com xyz

******************************Web Application Development in Java****************************
Softwares requirement:
--------------------------
1) Java Development Kit
JDK 8/17/21/23
JDK 17
https://download.oracle.com/java/17/archive/jdk-17.0.12_windows-x64_bin.msi

2) Database: Oracle 10g XE, MySQL 8, XAAMP (MySQL in-built)
Oracle 10g XE
https://www.youwindowsworld.com/en/downloads/database/oracle/oracle-database-express-10g-edition-xe/download-269-oracle-express-10g-xe

XAAMP
https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe

3) IDE (Integrated Development Environment)
Eclipse Enterprise Edition:
https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/2022-06/R/eclipse-jee-2022-06-R-win32-x86_64.zip

Eclipse/NetBeans/IntelliJ

4) Java Web Server
Tomcat 
https://archive.apache.org/dist/tomcat/tomcat-7/v7.0.99/bin/apache-tomcat-7.0.99-windows-x64.zip
													or
https://apache.root.lu/tomcat/tomcat-8/v8.5.93/bin/apache-tomcat-8.5.93-windows-x64.zip

5) For MySQL Database one JDBC driver jar file is required

https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-9.2.0.zip

Extract mysql-jconnector zip file mysql-connector-j-9.2.0.zip

Copy D:\Softwares\mysql-connector-j-9.2.0\mysql-connector-j-9.2.0\mysql-connector-j-9.2.0.jar into Tomcat lib directory D:\Softwares\apache-tomcat-7.0.99-windows-x64\apache-tomcat-7.0.99


Download Eclipse Enterprise Edition
eclipse-jee-2023-12-R-win32-x86_64.zip and extract it into C:\ or D:\Softwares directory

Download Tomcat 7 or 8.5 zip file also and extract it.

D:\Softwares\eclipse-jee-2023-12-R-win32-x86_64\eclipse\eclipse.exe
Workspace Directory: D:\A1 16GB\A_IARE\2024 PAT\SUB2
Workspace Directory: D:\SUB2
click on Finish

File-> New-> Dynamic Web Project-> 
Project Name: sub2_todo
In the Target Runtime-> Click on New Runtime-> Expand Apache-> Apache Tomcat 7.0
click on Next-> 
click on Browse-> 
D:\Softwares\apache-tomcat-7.0.99-windows-x64\apache-tomcat-7.0.99
click on Installed JREs
choose the path of JDK
C:\Program Files\Java\jdk1.8.0_202
click on Finish button
in the parent panel click on Next-> Next-> click on Generate web.xml checkbox
and then click on Finish

The web application directory structure looks like below:
sub2_todo
	src
		main
			java
			webapp
				web.xml
src
	main
		java			
			factory
				DBConn.java
			beans
				Register.java
				Task.java
			dao
				ToDoDAO.java
				ToDoDAOImpl.java
			servlets
				RegisterServlet.java
				LoginServlet.java
				AddTaskServlet.java
				TaskCompletedServlet.java
				LogoutServlet.java
		webapp
			Register.html
			Login.jsp
			ViewTasks.jsp
				

We are generating following classes and files:
beans.Register.java, beans.Task.java
factory.DBConn.java
dao.ToDoDAOIntf.java, dao.ToDoDAOImpl.java
Register.html, servlets.RegisterServlet.java
Login.html, servlets.LoginServlet.java
ViewTasks.jsp, servlets.AddTaskServlet.java, 
servlets.MarkTaskCompletedServlet.java
servlets.LogOutServlet.java
configure welcome-file in web.xml

Generate Java Beans
Right click on the project-> New-> Class
Package:beans
Name:Register
Click on Finish
package beans;

import java.util.Objects;

public class Register {

	private int regid;
	private String fname;
	private String lname;
	private String email;
	private String pass;
	private long mobile;
	private String address;
	public Register() {
		super();
		// TODO Auto-generated constructor stub
	}
	public Register(int regid, String fname, String lname, String email, String pass, long mobile, String address) {
		super();
		this.regid = regid;
		this.fname = fname;
		this.lname = lname;
		this.email = email;
		this.pass = pass;
		this.mobile = mobile;
		this.address = address;
	}
	public int getRegid() {
		return regid;
	}
	public void setRegid(int regid) {
		this.regid = regid;
	}
	public String getFname() {
		return fname;
	}
	public void setFname(String fname) {
		this.fname = fname;
	}
	public String getLname() {
		return lname;
	}
	public void setLname(String lname) {
		this.lname = lname;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getPass() {
		return pass;
	}
	public void setPass(String pass) {
		this.pass = pass;
	}
	public long getMobile() {
		return mobile;
	}
	public void setMobile(long mobile) {
		this.mobile = mobile;
	}
	public String getAddress() {
		return address;
	}
	public void setAddress(String address) {
		this.address = address;
	}
	@Override
	public int hashCode() {
		return Objects.hash(address, email, fname, lname, mobile, pass, regid);
	}
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Register other = (Register) obj;
		return Objects.equals(address, other.address) && Objects.equals(email, other.email)
				&& Objects.equals(fname, other.fname) && Objects.equals(lname, other.lname) && mobile == other.mobile
				&& Objects.equals(pass, other.pass) && regid == other.regid;
	}
	@Override
	public String toString() {
		return "Register [regid=" + regid + ", fname=" + fname + ", lname=" + lname + ", email=" + email + ", pass="
				+ pass + ", mobile=" + mobile + ", address=" + address + "]";
	}
	
	/* 
	 * public class
	 * private vars
	 * pair of public setter and getter methods for each field
	 * override equals(), hashCode() and toString() methods
	 */
	
}

package beans;

import java.util.Objects;

public class Task {

	private int taskId;
	private String taskName;
	private String taskDate;
	private int taskStatus;
	private int regId;
	public Task() {
		super();
		// TODO Auto-generated constructor stub
	}
	public Task(int taskId, String taskName, String taskDate, int taskStatus, int regId) {
		super();
		this.taskId = taskId;
		this.taskName = taskName;
		this.taskDate = taskDate;
		this.taskStatus = taskStatus;
		this.regId = regId;
	}
	public int getTaskId() {
		return taskId;
	}
	public void setTaskId(int taskId) {
		this.taskId = taskId;
	}
	public String getTaskName() {
		return taskName;
	}
	public void setTaskName(String taskName) {
		this.taskName = taskName;
	}
	public String getTaskDate() {
		return taskDate;
	}
	public void setTaskDate(String taskDate) {
		this.taskDate = taskDate;
	}
	public int getTaskStatus() {
		return taskStatus;
	}
	public void setTaskStatus(int taskStatus) {
		this.taskStatus = taskStatus;
	}
	public int getRegId() {
		return regId;
	}
	public void setRegId(int regId) {
		this.regId = regId;
	}
	@Override
	public int hashCode() {
		return Objects.hash(regId, taskDate, taskId, taskName, taskStatus);
	}
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Task other = (Task) obj;
		return regId == other.regId && Objects.equals(taskDate, other.taskDate) && taskId == other.taskId
				&& Objects.equals(taskName, other.taskName) && taskStatus == other.taskStatus;
	}
	@Override
	public String toString() {
		return "Task [taskId=" + taskId + ", taskName=" + taskName + ", taskDate=" + taskDate + ", taskStatus="
				+ taskStatus + ", regId=" + regId + "]";
	}
}

package factory;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConn {
	static Connection con;
	public static Connection con() {
		try {
			if(con==null) {
				Class.forName("com.mysql.jdbc.Driver");
				con=DriverManager.getConnection("jdbc:mysql://localhost:3306/sub2_todo","root","");
			}
		}catch(Exception e) {
			e.printStackTrace();
		}
		return con;
	}
}

package dao;

import java.util.List;

import beans.Register;
import beans.Task;

public interface ToDoDAOIntf {
	public abstract int register(Register register);
	int login(String email,String pass);
	public int addTask(int regId,Task task);
	public List<Task> findAllTasksByRegId(int regId);
	public boolean markTaskCompleted(int regId, int taskId);
	public String getFnameByRegId(int regId);
}
/*
 * In java interface all 
 * 	variables are public static final by default and
 * 	methods are public abstract by default
 * */
 
Write a sub class named ToDoDAOImpl for ToDoDAOIntf interface
Right click on the project-> New-> Class
package:dao
Name:ToDoDAOImpl
Super interface: ToDoDAOIntf
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import beans.Register;
import beans.Task;
import factory.DBConn;

public class ToDoDAOImpl implements ToDoDAOIntf {

	Connection con;
	Statement stmt;
	ResultSet rs;
	PreparedStatement pstmt1,pstmt2,pstmt3,pstmt4,pstmt5;
	
	// to make DAOImpl singleton, 
	// we need declare constructor as private
	// write one factory method that returns singleton 
	// instance of the same class
	private ToDoDAOImpl() {
		try {
			con=DBConn.getConn();
			stmt=con.createStatement();
			pstmt1=con.prepareStatement("insert into register values (?,?,?,?,?,?,?)");
			pstmt2=con.prepareStatement("insert into tasks values (?,?,?,?,?)");
			pstmt3=con.prepareStatement("insert into taskid_pks values (?,?)");
			pstmt4=con.prepareStatement("update taskid_pks set taskid=? where regid=?");
			pstmt5=con.prepareStatement("update tasks set taskstatus=3 where regid=? and taskid=?");
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	static ToDoDAOIntf dao=null;
	public static ToDoDAOIntf getInstance() {
		if(dao==null)
			dao=new ToDoDAOImpl();
		return dao;
	}
		
	@Override
	public int register(Register register) {
		int regid=0;
		try {
			rs=stmt.executeQuery("select max(regid) from register");
			if(rs.next()) {
				regid=rs.getInt(1);
			}
			regid++;
			
			pstmt1.setInt(1,regid);
			pstmt1.setString(2, register.getFname());
			pstmt1.setString(3, register.getLname());
			pstmt1.setString(4, register.getEmail());
			pstmt1.setString(5, register.getPass());
			pstmt1.setLong(6, register.getMobile());
			pstmt1.setString(7, register.getAddress());
			int i=pstmt1.executeUpdate();
			if(i==1)
				System.out.println("register inserted");
		} catch(Exception e) {
			e.printStackTrace();
		}
		return regid;
	}

	@Override
	public int login(String email, String pass) {
		int regId=0;
		try {
			rs=stmt.executeQuery("select regid from register where email='"+email+"' and pass='"+pass+"'");
			if(rs.next()) {
				regId=rs.getInt(1);
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		return regId;
	}

	@Override
	public int addTask(int regId, Task task) {
		int taskId=0;
		try {
			boolean isNew=true;
			rs=stmt.executeQuery("select taskid from taskid_pks where regid="+regId);
			if(rs.next()) {
				taskId=rs.getInt(1);
				isNew=false;
			}
			taskId++;
			
			con.setAutoCommit(false);
			int i,j=0;
			pstmt2.setInt(1, taskId);
			pstmt2.setString(2,task.getTaskName());
			pstmt2.setString(3, task.getTaskDate());
			pstmt2.setInt(4,task.getTaskStatus());
			pstmt2.setInt(5, regId);
			i=pstmt2.executeUpdate();
			
			if(isNew==true) {
				pstmt3.setInt(1,regId);
				pstmt3.setInt(2, taskId);
				j=pstmt3.executeUpdate();
			} else {
				pstmt4.setInt(1, taskId);
				pstmt4.setInt(2,  regId);
				j=pstmt4.executeUpdate();
			}
			if(i==1 && j==1) {
				con.commit();
				System.out.println("TX Success, Task Inserted");
			} else {
				con.rollback();
				System.out.println("TX Failed");
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		return taskId;
	}

	@Override
	public List<Task> findAllTasksByRegId(int regId) {
		List<Task> taskList=new ArrayList<Task>();
		try {
			rs=stmt.executeQuery("select * from tasks where regId="+regId);
			while(rs.next()) {
				Task task=new Task(rs.getInt(1),rs.getString(2),rs.getString(3),rs.getInt(4),rs.getInt(5));
				taskList.add(task);
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		return taskList;
	}

	@Override
	public boolean markTaskCompleted(int regId, int taskId)  	{
		boolean flag=false;
		try {
			pstmt5.setInt(1, regId);
			pstmt5.setInt(2, taskId);
			pstmt5.executeUpdate();
			flag=true;
		} catch(Exception e) {
			e.printStackTrace();
		}
		return flag;
	}
	
	public String getFnameByRegId(int regId) {
		String fname=null;
		try {
			rs=stmt.executeQuery("select fname from register where regid="+regId);
			if(rs.next()) {
				fname=rs.getString(1);
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		return fname;
	}	
}

Register.html-> RegisterServlet-> dao.register()
Login.jsp-> LoginServlet-> dao.login()
ViewTasks.jsp-> dao.findAllTasksByRegId()
AddTaskServlet-> dao.addTask()
MarkTaskCompletedServlet-> dao.markTaskCompleted()
LogOutServlet
						
1 html, 2 jsps, 5 Servlets

Right click on the project-> New-> HTML

Create Register.html file
Right click on the project-> New-> HTML File->
File name:Register.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="ISO-8859-1">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Registration Form</title>
    <!-- Bootstrap CSS link -->
    <link href="bootstrap.min.css" rel="stylesheet" integrity="sha384-KyZXEJ4v3Rt7TgLXfjYk2lFz7tvb1x1L8Vvuv8V5l5Oxf73/iwf/xm0tsw/y0Mjf" crossorigin="anonymous">
	<!-- Bootstrap JS and Popper.js links -->
	<script src="popper.min.js" integrity="sha384-oBqDVmMz4fnFO9gybG5aPA5dW29zAq7xkA2Ehu/2Q0cmSm3g5t7W7vcuRwrT2Zh4b" crossorigin="anonymous"></script>
	<script src="bootstrap.min.js" integrity="sha384-pzjw8f+ua7Kw1TIq0v8Fq5edhb6z9f+fnU7uRek3aDkfl3Fqq2yyDd5duQwBq+YF" crossorigin="anonymous"></script>

</head>
<body>

<div class="container">
    <h2 class="text-center my-4">Registration Form</h2>

    <form method="post" action="./RegisterServlet">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="mb-3">
                    <label for="fname" class="form-label">First Name</label>
                    <input type="text" name="fname" class="form-control" id="fname" required>
                </div>

                <div class="mb-3">
                    <label for="lname" class="form-label">Last Name</label>
                    <input type="text" name="lname" class="form-control" id="lname" required>
                </div>

                <div class="mb-3">
                    <label for="email" class="form-label">Email</label>
                    <input type="email" name="email" class="form-control" id="email" required>
                </div>

                <div class="mb-3">
                    <label for="pass" class="form-label">Password</label>
                    <input type="password" name="pass" class="form-control" id="pass" required>
                </div>

                <div class="mb-3">
                    <label for="mobile" class="form-label">Mobile</label>
                    <input type="text" name="mobile" class="form-control" id="mobile" required>
                </div>

                <div class="mb-3">
                    <label for="address" class="form-label">Address</label>
                    <textarea name="address" class="form-control" id="address" rows="4" required></textarea>
                </div>

                <div class="d-flex justify-content-between">
                    <button type="submit" name="submit" class="btn btn-primary">Register</button>
                    <button type="reset" name="reset" class="btn btn-secondary">Clear</button>
                </div>
            </div>
        </div>
    </form>

    <p class="text-center mt-3">Existing User, <a href="Login.jsp">Sign In</a></p>
</div>
</body>
</html>

Write a RegisterServlet.java
Right click on the project-> New-> Servlet
Java Package:servlets
Classname:RegisterServlet
click on Next-> Next-> uncheck doGet() checkbox and check only doPost() checkbox
click on Finish
package servlets;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import beans.Register;
import dao.ToDoDAOImpl;
import dao.ToDoDAOIntf;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/html");
		PrintWriter out=response.getWriter();
		
		// reading Register.html form data
		String fname=request.getParameter("fname").trim();		
		String lname=request.getParameter("lname").trim();		
		String email=request.getParameter("email").trim();
		String pass=request.getParameter("pass").trim();
		long mobile=Long.parseLong(request.getParameter("mobile").trim());
		String address=request.getParameter("address").trim();
		
		// storing data in Register bean
		Register reg=new Register(0,fname,lname,email,pass,mobile,address);
		
		ToDoDAOIntf dao=ToDoDAOImpl.getInstance();
		int regId=dao.register(reg);
		if(regId>0) {
			// response.sendRedirect("./Login.jsp");
			getServletContext().getRequestDispatcher("/Login.jsp").forward(request,response);
		} else
			out.println("Registration Failed");
	}
}


adding welcome file in web.xml
sub2_todo
 src
  main
   webapp
    WEB-INF
	 open web.xml
	 <welcome-file>Register.html</welcome-file>
	 
 Right click on the project-> RunAs-> Run on Server
 
Create Login.jsp
Right click on the project-> New-> JSP
File name:Login.jsp
click on Next-> Finish
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
Register.html-> RegisterServlet-> dao.register(reg)
Login.jsp-> LoginServlet-> dao.login(email,pass)
ViewTasks.jsp
			-> AddTaskServlet-> dao.addTask(regId,task)
			-> markTaskCompletedServlet-> dao.markTaskCompleted(regId, taskId)
			-> LogoutServlet.java
Login.jsp<->

Write a LoginServlet class
// LoginServlet.java
package servlets;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.ToDoDAOImpl;
import dao.ToDoDAOIntf;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/html");
		PrintWriter out=response.getWriter();
		HttpSession session=request.getSession();
		ServletContext context=getServletContext();
		
		// read email,pass from browser/form
		String email=request.getParameter("email").trim();		
		String pass=request.getParameter("pass").trim();
		
		boolean isValid=true;
		// fields not null validation
		if(email.length()==0 || pass.isEmpty()) {
			request.setAttribute("loginError", "Please fill Email/Pass");
			isValid=false;
		} else {
			// verify email & pass in DB
			ToDoDAOIntf dao=ToDoDAOImpl.getInstance();
			int regId=dao.login(email, pass);
			if(regId==0) {
				request.setAttribute("loginError", "Email/Pass is wrong");
				isValid=false;
			} else {
				session.setAttribute("regId", regId);
				context.getRequestDispatcher("/ViewTasks.jsp").forward(request,  response);
			}// else
		}// else
		if(isValid==false) {
			context.getRequestDispatcher("/Login.jsp").forward(request, response);
		}// if	
	}// doPost()
}// class

Right click on the project-> New-> JSP
Name:ViewTasks.jsp
<%@page import="beans.Task"%>
<%@page import="java.util.List"%>
<%@page import="dao.ToDoDAOImpl"%>
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
			ToDoDAOIntf dao=ToDoDAOImpl.getInstance();
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

// AddTaskServlet.java
package servlets;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import beans.Task;
import dao.ToDoDAOImpl;
import dao.ToDoDAOIntf;


@WebServlet("/AddTaskServlet")
public class AddTaskServlet extends HttpServlet {
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/html");
		PrintWriter out=response.getWriter();
		HttpSession session=request.getSession();
		ServletContext context=getServletContext();
		
		String taskName=request.getParameter("taskName").trim();
		String taskDate=request.getParameter("taskDate").trim();
		int taskStatus=Integer.parseInt(request.getParameter("taskStatus").trim());
		int regId=Integer.parseInt(session.getAttribute("regId").toString());
		Task task=new Task(0,taskName,taskDate,taskStatus,regId);
		
		ToDoDAOIntf dao=ToDoDAOImpl.getInstance();
		int taskId=dao.addTask(regId, task);
		if(taskId>0) {
			context.getRequestDispatcher("/ViewTasks.jsp").forward(request,  response);
		}
	}

}

// MarkTaskCompletedServlet.java
package servlets;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.ToDoDAOImpl;
import dao.ToDoDAOIntf;


@WebServlet("/MarkTaskCompletedServlet")
public class MarkTaskCompletedServlet extends HttpServlet {
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/html");
		PrintWriter out=response.getWriter();
		HttpSession session=request.getSession();
		ServletContext context=getServletContext();
		
		int regId=Integer.parseInt(request.getParameter("regId"));
		int taskId=Integer.parseInt(request.getParameter("taskId"));
		
		ToDoDAOIntf dao=ToDoDAOImpl.getInstance();
		boolean flag=dao.markTaskCompleted(regId, taskId);
		if(flag)
			response.sendRedirect("./ViewTasks.jsp");
		else
			out.println("TX Failed");
		
	}
}


// LogoutServlet.java
package servlets;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
   	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session=request.getSession();
		session.invalidate();
		response.sendRedirect("./Login.jsp");
	}

}

Goto GitHub, 
	create a repository name sub2_todo
	select Public radio button
	select Add a README file checkbox
	click on Create Repository

goto sub2 folder (our web project folder) where build, src folders exist

git --version
git init
dir (shows nothing)
dir /a:h (shows .git hidden folder)
git ls-files
git status
git add *.*
git status
git commit -m "sub2_todo project added to local repo"
git config --global user.name "activesurya"
git config --global user.email "activesurya@gmail.com"
git remote add origin https://github.com/activesurya/sub2_todo
git push -u origin main
