# frozen_string_literal: true

require "spec_helper"

require "uuid_migrations"
require "pry"

RSpec.describe UuidMigrations do
  it "has a version number" do
    expect(UuidMigrations::VERSION).not_to be nil
  end

  let(:migration_class) do
    Class.new(ActiveRecord::Migration[7.1]) do
      def change
        create_table :testings do |t|
          t.string "foo"
        end
      end
    end
  end

  let(:existing_migration_class) do
    Class.new(ActiveRecord::Migration[7.1]) do
      def change
        create_table :testings do |t|
          t.integer :uuid
          t.string "foo"
        end
      end
    end
  end

  describe "Postgresql adapter" do
    let(:config) do
      {
        test: {
          adapter: "postgresql",
          encoding: "unicode",
          database: "uuid_migrations_test",
          pool: 5,
          username: "postgres",
          password: "postgress"
        }
      }
    end
    let(:connection) {
      ActiveRecord::Base.establish_connection(:test)
      ActiveRecord::Base.connection
    }

    before do
      ActiveRecord::Base.configurations = config
      connection
    end

    after do
      connection.drop_table :testings
      connection.disconnect!
    end

    it "automatically adds uuid to active_record table definition" do
      migration_class.new("create_uuids_table", 123).migrate(:up)
      expect(connection).to be_column_exist(:testings, :uuid, :uuid)
    end

    it "does not change the uuid if it exists" do
      existing_migration_class.new("existing_uuids_table", 456).migrate(:up)

      expect(connection).to be_column_exist(:testings, :uuid, :integer)
    end

    it "does not add if version is inferior to start_with" do
      allow(UuidMigrations).to receive(:start_with).and_return(1000)
      migration_class.new("existing_uuids_table", 999).migrate(:up)

      expect(connection).not_to be_column_exist(:testings, :uuid)
    end
  end
end
