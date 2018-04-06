Sequel.migration do
    change do
        alter_table :comments do
            drop_column :text
            add_column :text, String, :null => false
        end
    end
end