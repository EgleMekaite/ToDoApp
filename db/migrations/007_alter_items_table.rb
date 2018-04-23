# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table :items do
      add_column :starred, TrueClass
      set_column_default :starred, false
    end
  end
end
