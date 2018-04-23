# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table :users do
      drop_column :updated_at
    end
  end
end
