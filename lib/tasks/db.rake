# frozen_string_literal: true

namespace :db do
  desc 'Run migrations'
  task :migrate, [:version] do |t, args|
    Sequel.extension :migration

    environment = ENV['RACK_ENV'] || 'development'
    db = Sequel.connect(YAML.safe_load(File.open('config/database.yml'))[environment])

    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(db, 'db/migrations', target: args[:version].to_i)
    else
      puts 'Migrating to latest'
      Sequel::Migrator.run(db, 'db/migrations')
    end
  end
end
