require "bcrypt"
require "sinatra/activerecord"
require "data_mapper"

module AuthStrategies
  class DatabaseManager
    def get(adapter = :active_record)
      case adapter
      when :active_record
        ActiveRecordAdapter.setup_tables
        ActiveRecordAdapter::UserModel
      when :data_mapper
        DataMapperAdapter.setup_tables
        DataMapperAdapter::UserModel
      else
        raise "Unsupported adapter #{adapter}"
      end
    end
  end

  module ActiveRecordAdapter
    module UserModel
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

  module DataMapperAdapter
    module UserModel
      class User
        include DataMapper::Resource
        include BCrypt

        property :id, Serial
        property :email, String, index: true
        property :password_hash, String

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
    end

    def self.setup_tables
      DataMapper.finalize
      UserModel::User.auto_upgrade!
    end
  end
end
