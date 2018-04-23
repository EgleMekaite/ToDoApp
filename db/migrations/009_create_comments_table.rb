# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :comments do
    primary_key :id
    String :text, :length => 300, :null => false
    foreign_key :user_id, :users, :null => false
    foreign_key :list_id, :lists, :null => false
    Date :creation_date
    Time :creation_time
    end
  end
end
