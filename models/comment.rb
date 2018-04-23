# user class
# frozen_string_literal: true

class Comment < Sequel::Model
  set_primary_key :id

  many_to_one :user
  many_to_one :list

  def validate
    super
    validates_presence :text, message: 'A comment must contain text'
  end

  def before_save
    self.creation_date = Time.now
    self.creation_time = Time.now
  end
end
