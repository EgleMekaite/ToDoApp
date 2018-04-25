# item class
# frozen_string_literal: true

class Item < Sequel::Model
  set_primary_key :id
  many_to_one :user
  many_to_one :list

  def validate
    super
    validates_presence :name, message: 'Item name cannot be blank'
  end

  def before_save
    self.updated_at = Time.now
    self.created_at ||= updated_at
  end
end
