Sequel.migration do
    change do
        alter_table :items do
            drop_column :due_date
            add_column :due_date, Date
        end
    end
end
