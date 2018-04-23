# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table :items do
      add_column :due_date, DateTime
    end
  end
end
