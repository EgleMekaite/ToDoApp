class List < Sequel::Model
    set_primary_key :id

    one_to_many :items, eager: [:user]
    one_to_many :permissions
    one_to_many :logs

    def self.new_list name, items, user
        list = List.create(name: name, created_at: Time.now)
        items.each do |item|
            Item.create(name: item[:name], description: item[:description], list: list, user: user,
            created_at: Time.now, updated_at: Time.now)
        end
        Permission.create(list: list, user: user, permission_level: 'read_write', created_at: Time.now,
        updated_at: Time.now)
        list
    end

    def validate
        super
        errors.add(:name, 'cannot be blank') if !name || name.empty?
        errors.add(:name, 'already taken') if name && new? && List[:name=>name]
        errors.add(:name, 'not a valid name') unless name =~ /\A[A-Za-z]/
    end

    def self.edit_list id, name, items, user
        list = List.first(id: id)
        list.name = name
        list.updated_at = Time.now
        list.save
        
        items.each do |item|
            if item[:deleted]
                i = Item.first(item[:id]).destroy
                next
            end
            i = Item.first(item[:id])
            if i.nil?
                Item.create(name: item[:name], description: item[:description], list: list, user: user,
                        created_at: Time.now, updated_at: Time.now)
            else
                i.name = item[:name]
                i.description = item[:description]
                i.updated_at = Time.now
                i.save
            end
        end
    end
end

class Item < Sequel::Model
    set_primary_key :id

    many_to_one :user
    many_to_one :list
end
