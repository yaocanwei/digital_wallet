require 'test_helper'

module DigitalWallet
  class WalletSystemTest < Minitest::Test
    def setup
      @wallet_system = WalletSystem.new
    end

    def test_create_wallet
      wallet = @wallet_system.create_wallet('user1')
      assert_equal 'user1', wallet.user_id
      assert_equal 0, wallet.balance
    end

    def test_deposit
      transaction = @wallet_system.deposit('user1', 100)
      
      assert_equal 100, @wallet_system.get_balance('user1')
      assert_equal 'deposit', transaction.transaction_type
      assert_equal 'user1', transaction.to_user
    end

    def test_withdraw
      @wallet_system.deposit('user1', 100)
      transaction = @wallet_system.withdraw('user1', 50)
      
      assert_equal 50, @wallet_system.get_balance('user1')
      assert_equal 'withdraw', transaction.transaction_type
      assert_equal 'user1', transaction.from_user
    end

    def test_transfer
      @wallet_system.deposit('user1', 100)
      transaction = @wallet_system.transfer('user1', 'user2', 30)
      
      assert_equal 70, @wallet_system.get_balance('user1')
      assert_equal 30, @wallet_system.get_balance('user2')
      assert_equal 'transfer', transaction.transaction_type
    end

    def test_insufficient_funds
      @wallet_system.deposit('user1', 50)
      
      assert_raises(InsufficientFundsError) do
        @wallet_system.withdraw('user1', 100)
      end

      assert_raises(InsufficientFundsError) do
        @wallet_system.transfer('user1', 'user2', 100)
      end
    end

    def test_invalid_amount
      assert_raises(InvalidAmountError) do
        @wallet_system.deposit('user1', -50)
      end

      assert_raises(InvalidAmountError) do
        @wallet_system.withdraw('user1', 0)
      end

      assert_raises(InvalidAmountError) do
        @wallet_system.transfer('user1', 'user2', -30)
      end
    end

    def test_user_not_found
      assert_raises(UserNotFoundError) do
        @wallet_system.get_balance('nonexistent')
      end

      assert_raises(UserNotFoundError) do
        @wallet_system.withdraw('nonexistent', 50)
      end
    end

    def test_get_transaction_history
      @wallet_system.deposit('user1', 100)
      @wallet_system.withdraw('user1', 30)
      @wallet_system.transfer('user1', 'user2', 20)

      history = @wallet_system.get_transaction_history('user1')
      
      assert_equal 3, history.size
      assert_equal 'deposit', history[0].transaction_type
      assert_equal 'withdraw', history[1].transaction_type
      assert_equal 'transfer', history[2].transaction_type
    end
  end
end
