package servlets;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import beans.Register;
import dao.ToDoDAOimpl;
import dao.ToDoDAOIntf;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        try {
            // reading Register.html form data
            String fname = request.getParameter("fname").trim();        
            String lname = request.getParameter("lname").trim();        
            String email = request.getParameter("email").trim();
            String pass = request.getParameter("pass").trim();
            long mobile = Long.parseLong(request.getParameter("mobile").trim());
            String address = request.getParameter("address").trim();
            
            // storing data in Register bean
            Register reg = new Register(0, fname, lname, email, pass, mobile, address);
            
            ToDoDAOIntf dao = ToDoDAOimpl.getInstance();
            int regId = dao.register(reg);
            if (regId > 0) {
                // forward to Login.jsp
                getServletContext().getRequestDispatcher("/Login.jsp").forward(request, response);
            } else {
                out.println("Registration Failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("An error occurred: " + e.getMessage());
        } finally {
            out.close();
        }
    }
}
