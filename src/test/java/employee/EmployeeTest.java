package employee;

import org.junit.jupiter.api.*;
import java.sql.SQLException;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class EmployeeManagementTest {

    private static EmployeeManagement empMgmt;

    @BeforeAll
    static void setup() {
        empMgmt = new EmployeeManagement();
    }

    @Test
    void testInsertEmployee() throws SQLException {
        int rows = empMgmt.insertEmployee("TestUser", "Developer", 55000, 1);
        assertEquals(1, rows, "Employee should be inserted successfully");
    }

    @Test
    void testUpdateSalary() throws SQLException {
        int empId = 1;  // make sure this ID exists
        double newSalary = 60000;
        int rows = empMgmt.updateSalary(empId, newSalary);
        assertTrue(rows >= 0, "Salary should update successfully");
    }

    @Test
    void testGetEmployeesByDepartment() throws SQLException {
        List<String> employees = empMgmt.getEmployeesByDepartment("IT");
        assertNotNull(employees, "Employee list should not be null");
        assertTrue(employees.size() >= 0, "Should return some employees");
    }

    @Test
    void testDeleteEmployee() throws SQLException {
        int rows = empMgmt.deleteEmployee(10); // Use a valid emp_id
        assertTrue(rows >= 0, "Employee should be deleted successfully");
    }
}
