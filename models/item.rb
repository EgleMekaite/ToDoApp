class Item < Sequel::Model
  set_primary_key :id
  many_to_one :user
  many_to_one :list
  
  def validate
    super
    errors.add(:name, 'The name cannot be blank') if !name || name.empty?
  end
  
end
