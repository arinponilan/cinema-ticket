package cinema.payment;

public class EWalletPayment implements Payment {
    private String walletType;
    private String phoneNumber;
    private double balance;

    public EWalletPayment(String walletType, String phoneNumber, double balance) {
        this.walletType = walletType;
        this.phoneNumber = phoneNumber;
        this.balance = balance;
    }

    @Override
    public boolean pay(double amount) {
        if (balance >= amount) {
            balance -= amount;
            return true;
        }
        return false;
    }

    @Override
    public boolean validate() {
        return phoneNumber != null && !phoneNumber.isEmpty();
    }

    @Override
    public String generateInvoice() {
        return "Invoice for E-Wallet: " + walletType + " (" + phoneNumber + ")";
    }

    @Override
    public String getPaymentInfo() {
        return "Wallet: " + walletType + ", Balance: " + balance;
    }

    // Getters and Setters
    public String getWalletType() { return walletType; }
    public void setWalletType(String walletType) { this.walletType = walletType; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public double getBalance() { return balance; }
    public void setBalance(double balance) { this.balance = balance; }
}

