package librarymanagementsystem;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LibraryManagement {

	private static final String DB_URL = "jdbc:mysql://localhost:3306/librarymanagementsystem";
	private static final String USER = "root";
	private static final String PASS = "root";

	private Connection conn;

	public LibraryManagement() throws SQLException {
		try {
			Class.forName("com.mysql.cj.jdbc.Driver"); // Load driver
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		conn = DriverManager.getConnection(DB_URL, USER, PASS);
	}

	// Issue a book
	public boolean issueBook(int studentId, int bookId) throws SQLException {
		String checkCopies = "SELECT available_copies FROM Book WHERE book_id=?";
		try (PreparedStatement ps = conn.prepareStatement(checkCopies)) {
			ps.setInt(1, bookId);
			ResultSet rs = ps.executeQuery();
			if (rs.next() && rs.getInt("available_copies") > 0) {
				conn.setAutoCommit(false);
				try {
					String issueBook = "INSERT INTO Issue (student_id, book_id, issue_date) VALUES (?, ?, NOW())";
					PreparedStatement psIssue = conn.prepareStatement(issueBook);
					psIssue.setInt(1, studentId);
					psIssue.setInt(2, bookId);
					psIssue.executeUpdate();

					String updateBook = "UPDATE Book SET available_copies = available_copies - 1 WHERE book_id=?";
					PreparedStatement psUpdate = conn.prepareStatement(updateBook);
					psUpdate.setInt(1, bookId);
					psUpdate.executeUpdate();

					conn.commit();
					return true;
				} catch (SQLException e) {
					conn.rollback();
					throw e;
				}
			}
		}
		return false;
	}

	// Return a book
	public boolean returnBook(int issueId) throws SQLException {
		conn.setAutoCommit(false);
		try {
			String returnBook = "UPDATE Issue SET return_date=NOW() WHERE issue_id=?";
			PreparedStatement ps = conn.prepareStatement(returnBook);
			ps.setInt(1, issueId);
			int updated = ps.executeUpdate();

			if (updated > 0) {
				String updateBook = "UPDATE Book b JOIN Issue i ON b.book_id=i.book_id " +
						"SET b.available_copies = b.available_copies + 1 WHERE i.issue_id=?";
				ps = conn.prepareStatement(updateBook);
				ps.setInt(1, issueId);
				ps.executeUpdate();
				conn.commit();
				return true;
			}
			conn.rollback();
			return false;
		} catch (SQLException e) {
			conn.rollback();
			throw e;
		}
	}

	// Search books
	public List<String> searchBook(String keyword) throws SQLException {
		String query = "SELECT title FROM Book WHERE title LIKE ? OR author LIKE ?";
		PreparedStatement ps = conn.prepareStatement(query);
		ps.setString(1, "%" + keyword + "%");
		ps.setString(2, "%" + keyword + "%");
		ResultSet rs = ps.executeQuery();

		List<String> results = new ArrayList<>();
		while (rs.next()) {
			results.add(rs.getString("title"));
		}
		return results;
	}

	// Student book history
	public List<String> getStudentHistory(int studentId) throws SQLException {
		String query = "SELECT b.title FROM Issue i JOIN Book b ON i.book_id=b.book_id WHERE i.student_id=?";
		PreparedStatement ps = conn.prepareStatement(query);
		ps.setInt(1, studentId);
		ResultSet rs = ps.executeQuery();

		List<String> books = new ArrayList<>();
		while (rs.next()) {
			books.add(rs.getString("title"));
		}
		return books;
	}

	public void close() throws SQLException {
		if (conn != null) conn.close();
	}
}
