class Aba
  module Validations
    attr_accessor :error_collection

    alias_method :errors, :error_collection

    BECS_PATTERN = /\A[\w\+\-\@\ \$\!\%\&\(\)\*\.\/\#\=\:\;\?\,\'\[\]\_\^]*\Z/
    INDICATORS = [' ', 'N', 'T', 'W', 'X', 'Y']

    def self.included(base)
      base.instance_eval do
        @_validations = Hash.new
      end

      base.extend(ClassMethods)
    end

    def valid?
      return !has_errors?
    end

    private

    # Run all validations
    def has_errors?
      self.error_collection = []

      self.class.instance_variable_get(:@_validations).each do |attribute, validations|
        value = send(attribute)

        validations.each do |type, param|
          case type
          when :presence
            self.error_collection << "#{attribute} is empty" if value.nil? || value.to_s.empty?
          when :bsb
            unless((param && value.nil?) || value =~ /^\d{3}-\d{3}$/)
              self.error_collection << "#{attribute} format is incorrect"
            end
          when :max_length
            self.error_collection << "#{attribute} length must not exceed #{param} characters" if value.to_s.length > param
          when :length
            self.error_collection << "#{attribute} length must be exactly #{param} characters" if value.to_s.length != param
          when :integer
            if param
              self.error_collection << "#{attribute} must be a number" unless value.to_s =~ /\A[+-]?\d+\Z/
            else
              self.error_collection << "#{attribute} must be an unsigned number" unless value.to_s =~ /\A\d+\Z/
            end
          when :account_number
            if value.to_s =~ /\A[0\ ]+\Z/ || value.to_s !~ /\A[a-z\d\ ]{1,9}\Z/
              self.error_collection << "#{attribute} must be a valid account number"
            end
          when :becs
            self.error_collection << "#{attribute} must not contain invalid characters" unless value.to_s =~ BECS_PATTERN
          when :indicator
            list = INDICATORS.join('\', \'')
            self.error_collection << "#{attribute} must be a one of '#{list}'" unless INDICATORS.include?(value.to_s)
          when :transaction_code
            self.error_collection << "#{attribute} must be a 2 digit number" unless value.to_s =~ /\A\d{2,2}\Z/
          end
        end
      end

      return !self.error_collection.empty?
    end

    module ClassMethods
      def inherited(subclass)
        subclass.instance_variable_set(:@_validations, @_validations.dup)
      end

      def inherit_validations(value = true)
        @_validations = Hash.new unless value
      end

      def validates_presence_of(*attributes)
        attributes.each do |attribute|
          add_validation_attribute(attribute, :presence)
        end
      end

      def validates_bsb(attribute, options = {})
        options[:allow_blank] ||= false
        add_validation_attribute(attribute, :bsb, options[:allow_blank])
      end

      def validates_max_length(attribute, length)
        add_validation_attribute(attribute, :max_length, length)
      end

      def validates_length(attribute, length)
        add_validation_attribute(attribute, :length, length)
      end

      def validates_integer(attribute, signed = true)
        add_validation_attribute(attribute, :integer, signed)
      end

      def validates_account_number(attribute)
        add_validation_attribute(attribute, :account_number)
      end

      def validates_becs(attribute)
        add_validation_attribute(attribute, :becs)
      end

      def validates_indicator(attribute)
        add_validation_attribute(attribute, :indicator)
      end

      def validates_transaction_code(attribute)
        add_validation_attribute(attribute, :transaction_code)
      end

      private

      def add_validation_attribute(attribute, type, param = true)
        @_validations[attribute] = Hash.new unless @_validations[attribute]
        @_validations[attribute][type] = param
      end
    end
  end
end
