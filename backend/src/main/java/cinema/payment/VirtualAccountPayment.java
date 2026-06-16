package cinema.payment;

public class VirtualAccountPayment implements Payment {
    private String walletType;
    private String phoneNumber;
    private double walletBalance;

    public VirtualAccountPayment(String walletType, String phoneNumber, double walletBalance) {
        this.walletType = walletType;
        this.phoneNumber = phoneNumber;
        this.walletBalance = walletBalance;
    }

    @Override
    public boolean validate() {
        return walletType != null && !walletType.isEmpty() && 
               phoneNumber != null && !phoneNumber.isEmpty();
    }

    @Override
    public boolean pay(double amount) {
        if (walletBalance >= amount) {
            walletBalance -= amount;
            return true;
        }
        return false;
    }

    @Override
    public String generateInvoice() {
        return "Invoice for Virtual Account " + walletType + " (" + phoneNumber + ")";
    }

    @Override
    public String getPaymentInfo() {
        return walletType + " - " + phoneNumber;
    }
}
