# frozen_string_literal: true

require "spec_helper"

require "uuid_migrations"
require "pry"

RSpec.describe UuidMigrations do
  it "has a version number" do
    expect(UuidMigrations::VERSION).not_to be nil
  end

  describe "Postgresql adapter" do
    let(:adapter) { ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.new(nil, nil) }

    it "automatically adds uuid to active_record table definition" do
      td = adapter.build_create_table_definition("foo")
      column = td[:uuid]
      expect(column.name).to eq("uuid")
      expect(column.type).to eq(:uuid)
      expect(column.options[:default].call).to eq "gen_random_uuid()"
    end

    it "does not change the uuid if it exists" do
      td = adapter.build_create_table_definition("foo") do |t|
        t.column :uuid, :integer
      end
      column = td[:uuid]
      expect(column.type).to eq(:integer)
    end
  end
end
