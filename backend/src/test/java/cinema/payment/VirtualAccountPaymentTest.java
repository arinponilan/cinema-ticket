package cinema.payment;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class VirtualAccountPaymentTest {

    @Test
    public void testValidateSuccess() {
        VirtualAccountPayment payment = new VirtualAccountPayment("Mandiri", "08123456789", 50000);
        assertTrue(payment.validate(), "Valid Virtual Account credentials should pass validation");
    }

    @Test
    public void testValidateFailureEmptyWalletType() {
        VirtualAccountPayment payment = new VirtualAccountPayment("", "08123456789", 50000);
        assertFalse(payment.validate(), "Empty wallet type should fail validation");
    }

    @Test
    public void testValidateFailureNullPhoneNumber() {
        VirtualAccountPayment payment = new VirtualAccountPayment("Mandiri", null, 50000);
        assertFalse(payment.validate(), "Null phone number should fail validation");
    }
}
