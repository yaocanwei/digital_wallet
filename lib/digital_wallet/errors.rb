# lib/digital_wallet/errors.rb
module DigitalWallet
  class Error < StandardError; end
  class InsufficientFundsError < Error; end
  class UserNotFoundError < Error; end
  class InvalidAmountError < Error; end
end
