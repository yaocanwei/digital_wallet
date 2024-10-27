# lib/digital_wallet/utils/logger.rb
require 'logger'
require 'json'
require 'fileutils'

module DigitalWallet
  class WalletLogger
    LEVELS = {
      debug: Logger::DEBUG,
      info: Logger::INFO,
      warn: Logger::WARN,
      error: Logger::ERROR,
      fatal: Logger::FATAL
    }.freeze

    DEFAULT_LOG_SIZE = 1024 * 1024 * 10  # 10MB
    DEFAULT_LOG_AGE = 'daily'
    DEFAULT_LOG_COUNT = 7

    def initialize(log_file = 'wallet_system.log', options = {})
      @log_file = log_file
      setup_log_directory
      
      @logger = Logger.new(
        @log_file,
        DEFAULT_LOG_COUNT,            # number of old logs to keep
        DEFAULT_LOG_SIZE,             # max log size
        datetime_format: '%Y%m%d'     # date format for rotated files
      )
      
      @logger.formatter = method(:formatter)
      @logger.level = options[:level] || Logger::INFO
    rescue StandardError => e
      warn "Failed to create log file: #{e.message}. Using STDOUT instead."
      @logger = Logger.new(STDOUT)
      @logger.formatter = method(:formatter)
    end

    def log(level, event, data = {})
      return unless LEVELS.key?(level)

      @logger.add(LEVELS[level]) do
        format_log_entry(event, sanitize_data(data))
      end
    rescue StandardError => e
      warn "Logging failed: #{e.message}"
    end

    private

    def setup_log_directory
      log_dir = File.dirname(@log_file)
      FileUtils.mkdir_p(log_dir) unless File.directory?(log_dir)
    end

    def formatter(severity, timestamp, progname, msg)
      timestamp_str = timestamp.strftime('%Y-%m-%d %H:%M:%S.%L')
      "[#{timestamp_str}] [#{severity}] #{msg}\n"
    end

    def format_log_entry(event, data)
      log_entry = {
        event: event,
        timestamp: Time.now.utc.iso8601(3),
        data: data,
        pid: Process.pid
      }
      JSON.generate(log_entry)
    end

    def sanitize_data(data)
      data_copy = deep_copy(data)
      sanitize_sensitive_fields(data_copy)
    end

    def deep_copy(obj)
      case obj
      when Hash
        obj.transform_values { |v| deep_copy(v) }
      when Array
        obj.map { |v| deep_copy(v) }
      else
        obj
      end
    end

    def sanitize_sensitive_fields(data)
      case data
      when Hash
        data.each do |k, v|
          if sensitive_field?(k)
            data[k] = mask_sensitive_data(v)
          else
            sanitize_sensitive_fields(v)
          end
        end
      when Array
        data.each { |v| sanitize_sensitive_fields(v) }
      end
      data
    end

    def sensitive_field?(field)
      sensitive_fields = %w[password credit_card ssn key secret token]
      field.to_s.downcase.match?(Regexp.union(sensitive_fields))
    end

    def mask_sensitive_data(value)
      return value if value.nil?
      return '****' if value.is_a?(String)
      value
    end
  end
end
