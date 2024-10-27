# test/digital_wallet/utils/logger_test.rb
require 'test_helper'
require 'tempfile'

module DigitalWallet
  class WalletLoggerTest < Minitest::Test
    def setup
      @temp_log = Tempfile.new(['wallet_system', '.log'])
      @logger = WalletLogger.new(@temp_log.path)
    end

    def teardown
      @temp_log.close
      @temp_log.unlink
    end

    def test_log_info
      @logger.log(:info, 'test_event', { user_id: 'user1', amount: '100' })
      
      log_content = File.read(@temp_log.path)
      assert_match(/\[INFO\]/, log_content)
      assert_match(/"event":"test_event"/, log_content)
      assert_match(/"user_id":"user1"/, log_content)
      assert_match(/"amount":"100"/, log_content)
    end

    def test_log_error
      @logger.log(:error, 'error_event', { error: 'test error' })
      
      log_content = File.read(@temp_log.path)
      assert_match(/\[ERROR\]/, log_content)
      assert_match(/"event":"error_event"/, log_content)
      assert_match(/"error":"test error"/, log_content)
    end

    def test_sanitize_sensitive_data
      @logger.log(:info, 'sensitive_data', {
        user_id: 'user1',
        password: 'secret123',
        credit_card: '4111111111111111',
        details: {
          ssn: '123-45-6789',
          token: 'abc123'
        }
      })

      log_content = JSON.parse(File.read(@temp_log.path).split('] ').last)
      data = log_content['data']

      assert_equal 'user1', data['user_id']
      assert_equal '****', data['password']
      assert_equal '****', data['credit_card']
      assert_equal '****', data['details']['ssn']
      assert_equal '****', data['details']['token']
    end

    def test_invalid_log_level
      @logger.log(:invalid_level, 'test_event', {})
      assert_empty File.read(@temp_log.path)
    end
  end
end
