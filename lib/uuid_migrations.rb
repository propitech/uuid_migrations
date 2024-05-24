# frozen_string_literal: true

require "active_record"

module UuidMigrations
  mattr_accessor :start_with

  def add_uuid_column(td)
    return td if UuidMigrations.start_with.present? && version < UuidMigrations.start_with

    td.column(:uuid, :uuid, default: -> { "gen_random_uuid()" }) if td[:uuid].blank?
    td
  end

  def create_table(...)
    if block_given?
      super do |td|
        yield(td)
        add_uuid_column(td)
      end
    else
      super
    end
  end
end

ActiveRecord::Migration.prepend UuidMigrations
ActiveRecord::Migration::Current.prepend UuidMigrations
