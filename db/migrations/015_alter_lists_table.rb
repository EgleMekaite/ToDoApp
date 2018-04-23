# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table :lists do
      add_column :updated_at, DateTime
    end
  end
end
