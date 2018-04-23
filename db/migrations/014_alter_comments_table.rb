# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table :comments do
      add_column :creation_time, Time
    end
  end
end
