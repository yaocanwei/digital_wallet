require 'test_helper'

module DigitalWallet
  class WalletTest < Minitest::Test
    def setup
      @wallet = Wallet.new('user1')
    end

    def test_wallet_initialization
      assert_equal 'user1', @wallet.user_id
      assert_equal BigDecimal('0'), @wallet.balance
      assert_empty @wallet.transactions
    end

    def test_add_transaction
      transaction = Transaction.new(
        from_user: nil,
        to_user: 'user1',
        amount: 100,
        transaction_type: 'deposit'
      )
      
      @wallet.add_transaction(transaction)
      assert_equal 1, @wallet.transactions.size
      assert_equal transaction, @wallet.transactions.first
    end

    def test_update_balance
      @wallet.update_balance(BigDecimal('100'))
      assert_equal BigDecimal('100'), @wallet.balance

      @wallet.update_balance(BigDecimal('-50'))
      assert_equal BigDecimal('50'), @wallet.balance
    end

    def test_to_log_format
      @wallet.update_balance(BigDecimal('100'))
      log_format = @wallet.to_log_format
      
      assert_equal @wallet.user_id, log_format[:user_id]
      assert_equal @wallet.balance.to_s('F'), log_format[:balance]
      assert_equal 0, log_format[:transaction_count]
    end
  end
end 
