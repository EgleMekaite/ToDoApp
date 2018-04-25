# list class
# frozen_string_literal: true

require 'pry'
class List < Sequel::Model
  set_primary_key :id

  one_to_many :items, eager: [:user]
  one_to_many :permissions
  one_to_many :logs
  one_to_many :comments

  def before_save
    self.updated_at = Time.now
    self.created_at ||= updated_at
  end

  def validate
    super
    validates_presence :name, message: 'Name cannot be blank'
  end

  def delete_list(list_id, items)
    list = List.first(id: list_id)
    permissions = list.permissions
    comments = list.comments
    items.each(&:destroy)
    permissions.each(&:destroy)
    comments.each(&:destroy)
    list.destroy
  end
end
