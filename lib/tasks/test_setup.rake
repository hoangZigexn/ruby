namespace :test do
  desc "Setup test database"
  task :setup => :environment do
    # Create test database if it doesn't exist
    config = ActiveRecord::Base.configurations['test']
    database_name = config['database']
    
    # Connect to MySQL server without specifying database
    connection = ActiveRecord::Base.establish_connection(
      config.merge('database' => nil)
    ).connection
    
    # Create database if it doesn't exist
    connection.execute("CREATE DATABASE IF NOT EXISTS #{database_name}")
    
    # Connect to test database
    ActiveRecord::Base.establish_connection(config)
    
    # Run migrations
    ActiveRecord::Migrator.migrate(Rails.root.join('db', 'migrate'))
    
    puts "Test database setup completed!"
  end
  
  desc "Clean test database"
  task :clean => :environment do
    config = ActiveRecord::Base.configurations['test']
    database_name = config['database']
    
    # Connect to MySQL server without specifying database
    connection = ActiveRecord::Base.establish_connection(
      config.merge('database' => nil)
    ).connection
    
    # Drop test database
    connection.execute("DROP DATABASE IF EXISTS #{database_name}")
    
    puts "Test database cleaned!"
  end
end

# Automatically setup test database before running tests
Rake::Task['test:units'].enhance(['test:setup'])
Rake::Task['test:functionals'].enhance(['test:setup'])
Rake::Task['test:integration'].enhance(['test:setup'])
