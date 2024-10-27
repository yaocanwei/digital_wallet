# test/digital_wallet/models/transaction_test.rb
require 'test_helper'

module DigitalWallet
  class TransactionTest < Minitest::Test
    def setup
      @transaction = Transaction.new(
        from_user: 'user1',
        to_user: 'user2',
        amount: 100,
        transaction_type: 'transfer'
      )
    end

    def test_transaction_initialization
      assert_equal 'user1', @transaction.from_user
      assert_equal 'user2', @transaction.to_user
      assert_equal BigDecimal('100'), @transaction.amount
      assert_equal 'transfer', @transaction.transaction_type
    end

    def test_to_log_format
      log_format = @transaction.to_log_format
      assert_equal @transaction.id, log_format[:transaction_id]
      assert_equal @transaction.from_user, log_format[:from_user]
      assert_equal @transaction.to_user, log_format[:to_user]
      assert_equal @transaction.amount.to_s('F'), log_format[:amount]
    end
  end
end
