# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table :comments do
      drop_column :creation_time
    end
  end
end
