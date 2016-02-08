require 'bcrypt'
require 'sinatra/activerecord'

module AuthStrategies
  class DatabaseManager
    def get(adapter = :active_record)
      case adapter
      when :active_record
        ActiveRecordAdapter.setup_tables
        ActiveRecordAdapter::User
      else
        raise "Unsupported adapter #{adapter}"
      end
    end
  end

  module ActiveRecordAdapter
    class User < ActiveRecord::Base
      include BCrypt
      validates :email, :password_hash, presence: true

      def password
        @password ||= Password.new(password_hash)
      end

      def password=(password)
        @password = Password.create(password)
        self.password_hash = @password
      end

      def authenticate(raw_password)
        password == raw_password
      end
    end

    class CreateUsers < ActiveRecord::Migration
      def self.up
        create_table :users do |t|
          t.string :email
          t.string :password_hash

          t.timestamps
        end

        add_index :users, :email, :unique => true
      end

      def self.down
        remove_index :users, :email
        drop_table :users
      end
    end

    def self.setup_tables
      unless ActiveRecord::Base.connection.table_exists?('users')
        CreateUsers.up
      end
    end
  end
end
