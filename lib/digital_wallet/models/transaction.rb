# lib/digital_wallet/models/transaction.rb
require 'time'
require 'securerandom'
require 'bigdecimal'

module DigitalWallet
  class Transaction
    attr_reader :id, :from_user, :to_user, :amount, :transaction_type, :timestamp
    VALID_TYPES = %w[deposit withdraw transfer].freeze

    def initialize(from_user:, to_user:, amount:, transaction_type:)
      @id = SecureRandom.uuid
      @from_user = from_user
      @to_user = to_user
      @amount = BigDecimal(amount.to_s)
      @transaction_type = validate_transaction_type(transaction_type)
      @timestamp = Time.now
    end

    def to_log_format
      {
        transaction_id: id,
        from_user: from_user,
        to_user: to_user,
        amount: amount.to_s('F'),
        type: transaction_type,
        timestamp: timestamp.iso8601(3)
      }
    end

    private

    def validate_transaction_type(type)
      raise ArgumentError, "Invalid transaction type" unless VALID_TYPES.include?(type)
      type
    end
  end
end
