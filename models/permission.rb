# permission class
# frozen_string_literal: true

class Permission < Sequel::Model
  many_to_one :user
  many_to_one :list
end
