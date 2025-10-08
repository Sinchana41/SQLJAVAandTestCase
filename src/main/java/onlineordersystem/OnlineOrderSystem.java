package onlineordersystem;


import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OnlineOrderSystem {
	private static final String URL = "jdbc:mysql://localhost:3306/onlineordersystem";
	private static final String USER = "root";
	private static final String PASS = "root";

	//  Insert Order + Transaction Update
	public boolean insertOrder(int custId, double amount) throws SQLException {
		Connection conn = DriverManager.getConnection(URL, USER, PASS);
		conn.setAutoCommit(false);
		try {
			PreparedStatement ps1 = conn.prepareStatement(
					"INSERT INTO orders (cust_id, order_date, amount) VALUES (?, NOW(), ?)");
			ps1.setInt(1, custId);
			ps1.setDouble(2, amount);
			ps1.executeUpdate();

			PreparedStatement ps2 = conn.prepareStatement(
					"UPDATE customer SET last_order_date = NOW() WHERE cust_id=?");
			ps2.setInt(1, custId);
			ps2.executeUpdate();

			conn.commit();
			return true;
		} catch (Exception e) {
			conn.rollback();
			throw e;
		} finally {
			conn.close();
		}
	}

	//  Get Order History
	public List<Double> getOrderHistory(int custId) throws SQLException {
		List<Double> orders = new ArrayList<>();
		try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
			 PreparedStatement ps = conn.prepareStatement("SELECT amount FROM orders WHERE cust_id=?")) {
			ps.setInt(1, custId);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) orders.add(rs.getDouble("amount"));
		}
		return orders;
	}

	//  Top 3 Customers
	public List<String> getTop3Customers() throws SQLException {
		List<String> top = new ArrayList<>();
		try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
			 PreparedStatement ps = conn.prepareStatement("""
                 SELECT c.cust_name FROM Customer c
                 JOIN Orders o ON c.cust_id=o.cust_id
                 GROUP BY c.cust_id
                 ORDER BY SUM(o.amount) DESC
                 LIMIT 3
             """)) {
			ResultSet rs = ps.executeQuery();
			while (rs.next()) top.add(rs.getString("cust_name"));
		}
		return top;
	}
}
