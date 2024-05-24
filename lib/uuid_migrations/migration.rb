# frozen_string_literal: true

module UuidMigrations
  module Migration
    def migrate(direction)
      uuid_migrations.checker.direction = direction
      super
    end
  end
end
