ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  # Setup database for each test
  setup do
    # Create new test database with unique name
    @test_db_name = "app_test_#{Time.now.to_i}_#{rand(10000)}"
    
    # Get connection info from config
    config = ActiveRecord::Base.configurations['test']
    
    # Create new database (connect to MySQL server without specifying database)
    connection = ActiveRecord::Base.establish_connection(
      config.merge('database' => nil)
    ).connection
    
    # Create database
    connection.execute("CREATE DATABASE #{@test_db_name}")
    
    # Connect to new database
    ActiveRecord::Base.establish_connection(
      config.merge('database' => @test_db_name)
    )
    
    # Run migrations to create schema
    ActiveRecord::Migrator.migrate(Rails.root.join('db', 'migrate'))
  end
  
  # Cleanup after each test
  teardown do
    # Drop test database
    if @test_db_name
      begin
        config = ActiveRecord::Base.configurations['test']
        connection = ActiveRecord::Base.establish_connection(
          config.merge('database' => nil)
        ).connection
        connection.execute("DROP DATABASE IF EXISTS #{@test_db_name}")
      rescue => e
        puts "Warning: Could not drop test database #{@test_db_name}: #{e.message}"
      end
    end
  end
end
