require "active_support/concern"
require "witness_protection/version"

module WitnessProtection

  extend ActiveSupport::Concern

  included do
    require "bcrypt"

    class << self

      def protected_identity(identity_column, *args)

        define_method "#{identity_column}=" do |value|
          super self.class.__encrypt_protected_token__(value)
        end

        define_method "encrypt_#{identity_column}" do |&blk|
          self.__encrypt_protected_token__(identity_column, &blk)
        end

        define_singleton_method "identify_by_#{identity_column}" do |token|
          self.__identify_by_protected_token__(identity_column, token)
        end

        define_singleton_method "identify_by_#{identity_column}!" do |token|
          self.__identify_by_protected_token__!(identity_column, token)
        end

      end

      def __identify_by_protected_token__(column, token)
        send("find_by_#{column}", __encrypt_protected_token__(token))
      end

      def __identify_by_protected_token__!(column, token)
        record = __identify_by_protected_token__(column, token)
        raise ActiveRecord::RecordNotFound unless record
        return record
      end

      def __encryption_salt__
        unless salt = ENV["ENCRYPTION_SALT"]
          fail "Can't find `ENCRYPTION_SALT' in environment."
        end
        return salt
      end

      def __encrypt_protected_token__(token)
        BCrypt::Engine.hash_secret(token, __encryption_salt__)
      end

    end

  end

  def __generate_protected_token__(identity_column, &generator)
    raise ArgumentError unless identity_column
    return instance_eval(&generator) if block_given?

    generation_method = "generate_#{identity_column}"
    return send(generation_method) if respond_to?(generation_method)
    return SecureRandom.urlsafe_base64
  end


  def __encrypt_protected_token__(identity_column, &generator)
    raise ArgumentError unless identity_column

    token = nil

    self[identity_column] = loop do
      token = __generate_protected_token__(identity_column, &generator)
      hash = self.class.__encrypt_protected_token__(token)
      break hash unless self.class.exists? identity_column => hash
    end

    return token
  end

end
