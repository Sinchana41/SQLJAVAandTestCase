package onlineordersystem;

import org.junit.jupiter.api.*;
import java.sql.SQLException;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

public class OnlineOrderSystemTest {
    static OnlineOrderSystem order;

    @BeforeAll
    static void init() {
        order = new OnlineOrderSystem();
    }

    @Test
    void testInsertOrder() throws SQLException {
        assertTrue(order.insertOrder(1, 5000.0));
    }

    @Test
    void testOrderHistory() throws SQLException {
        List<Double> list = order.getOrderHistory(1);
        assertNotNull(list);
    }

    @Test
    void testTop3Customers() throws SQLException {
        List<String> top = order.getTop3Customers();
        assertTrue(top.size() <= 3);
    }
}
