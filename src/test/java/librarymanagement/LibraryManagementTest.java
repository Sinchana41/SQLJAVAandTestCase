package librarymanagement;

import librarymanagementsystem.LibraryManagement;
import org.junit.jupiter.api.*;
import java.sql.SQLException;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class LibraryManagementTest {

    private LibraryManagement lib;

    @BeforeAll
    void setup() throws SQLException {
        lib = new LibraryManagement();
    }

    @AfterAll
    void tearDown() throws SQLException {
        lib.close();
    }

    @Test
    void testIssueBook_Success() throws SQLException {
        boolean result = lib.issueBook(1, 1); // assuming student_id=1, book_id=1 exists
        assertTrue(result, "Book should be issued successfully");
    }

    @Test
    void testIssueBook_NoCopies() throws SQLException {
        boolean result = lib.issueBook(1, 999); // non-existent book
        assertFalse(result, "Should fail for invalid book id");
    }

    @Test
    void testReturnBook_Success() throws SQLException {
        boolean result = lib.returnBook(1); // assuming issue_id=1 exists
        assertTrue(result, "Book should be returned successfully");
    }

    @Test
    void testSearchBook_Found() throws SQLException {
        List<String> results = lib.searchBook("Java");
        assertNotNull(results);
        assertTrue(results.size() > 0, "Should find books with 'Java' in title or author");
    }

    @Test
    void testGetStudentHistory() throws SQLException {
        List<String> history = lib.getStudentHistory(1);
        assertNotNull(history);
        assertTrue(history.size() >= 0, "Should return student's issue history");
    }
}
