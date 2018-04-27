# permission class
# frozen_string_literal: true

class Permission < Sequel::Model
  many_to_one :user
  many_to_one :list

  def before_save
    self.updated_at = Time.now
    self.created_at ||= updated_at
  end
end
