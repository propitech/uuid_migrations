# frozen_string_literal: true

require "active_record"
require "active_record/connection_adapters/postgresql_adapter"

module UuidMigrations
  def build_create_table_definition(table_name, **options)
    td = super
    td.column(:uuid, :uuid, default: -> { "gen_random_uuid()" }) if td[:uuid].blank?
    td
  end
end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend UuidMigrations
