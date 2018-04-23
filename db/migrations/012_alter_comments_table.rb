# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table :comments do
      drop_column :text
      add_column :text, String, default: !nil
    end
  end
end
