package employee;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EmployeeManagement {

	static final String DB_URL = "jdbc:mysql://localhost:3306/employee_d_b";
	static final String USER = "root";
	static final String PASS = "root";


	//  1. Get employees by department
	public List<String> getEmployeesByDepartment(String deptName) throws SQLException {
		List<String> employees = new ArrayList<>();

		try (Connection conn = DriverManager.getConnection(DB_URL, USER, PASS)) {
			String query = "SELECT e.name FROM employee e JOIN department d ON e.dept_id=d.dept_id WHERE d.dept_name=?";
			PreparedStatement ps = conn.prepareStatement(query);
			ps.setString(1, deptName);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				employees.add(rs.getString("name"));
			}
		}
		return employees;
	}

	// 2. Insert new employee
	public int insertEmployee(String name, String designation, double salary, int deptId) throws SQLException {
		try (Connection conn = DriverManager.getConnection(DB_URL, USER, PASS)) {
			String sql = "INSERT INTO employee (name, designation, salary, dept_id) VALUES (?, ?, ?, ?)";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setString(1, name);
			ps.setString(2, designation);
			ps.setDouble(3, salary);
			ps.setInt(4, deptId);
			return ps.executeUpdate();
		}
	}

	//  3. Update employee salary
	public int updateSalary(int empId, double newSalary) throws SQLException {
		try (Connection conn = DriverManager.getConnection(DB_URL, USER, PASS)) {
			String sql = "UPDATE employee SET salary=? WHERE emp_id=?";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setDouble(1, newSalary);
			ps.setInt(2, empId);
			return ps.executeUpdate();
		}
	}

	//  4. Delete employee
	public int deleteEmployee(int empId) throws SQLException {
		try (Connection conn = DriverManager.getConnection(DB_URL, USER, PASS)) {
			String sql = "DELETE FROM employee WHERE emp_id=?";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setInt(1, empId);
			return ps.executeUpdate();
		}
	}
}

