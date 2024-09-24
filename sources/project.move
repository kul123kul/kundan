module MyModule::P2PLending {

    use aptos_framework::coin;
    use aptos_framework::signer;
    use aptos_framework::aptos_coin::{AptosCoin};

    struct Loan has store, key {
        lender: address,
        borrower: address,
        loan_amount: u64,
        interest_rate: u64, // Interest rate in percentage
        is_repaid: bool,
    }

    // Function to lend funds to a borrower
    public fun lend_funds(lender: &signer, borrower: address, loan_amount: u64, interest_rate: u64) {
        let loan = Loan {
            lender: signer::address_of(lender),
            borrower,
            loan_amount,
            interest_rate,
            is_repaid: false,
        };

        // Transfer loan amount to borrower
        coin::transfer<AptosCoin>(lender, borrower, loan_amount);

        // Store loan information
        move_to(lender, loan);
    }

    // Function to repay the loan
    public fun repay_loan(borrower: &signer, lender: address) acquires Loan {
        let loan = borrow_global_mut<Loan>(lender);

        // Ensure loan has not been repaid
        assert!(!loan.is_repaid, 1);

        // Calculate repayment amount (loan amount + interest)
        let repayment_amount = loan.loan_amount + (loan.loan_amount * loan.interest_rate / 100);

        // Transfer repayment amount to lender
        coin::transfer<AptosCoin>(borrower, loan.lender, repayment_amount);

        // Mark loan as repaid
        loan.is_repaid = true;
    }
}
