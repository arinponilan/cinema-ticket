package cinema.payment;

public interface Payment {
    boolean pay(double amount);
    boolean validate();
    String generateInvoice();
    String getPaymentInfo();
}

