require 'pry'
class List < Sequel::Model
    set_primary_key :id

    one_to_many :items, eager: [:user]
    one_to_many :permissions
    one_to_many :logs
    one_to_many :comments

    attr_writer :item

    def before_save
        self.updated_at = Time.now
        self.created_at ||= updated_at
    end

    def self.new_list(name, items, user)
        list = List.create(name: name)
        items.each do |item|
            if item[:starred].nil?
                checked = 0
            else
                checked = 1
            end
            Item.create(name: item[:name], description: item[:description], starred: checked, due_date: item[:due_date], list: list, user: user,
            created_at: Time.now, updated_at: Time.now)
        end
        Permission.create(list: list, user: user, permission_level: 'read_write', created_at: Time.now,
        updated_at: Time.now)
        list.save
    end

    def validate
        super
        errors.add(:items, 'must include at least one item') if !items || items.nil?
        errors.add(:name, 'cannot be blank') if !name || name.empty?
        errors.add(:name, 'not a valid name') unless name =~ /\A[A-Za-z]/
    end

    def edit_list id, name, items, starred, user
        list = List.first(id: id)
        list.name = name
        items.each do |item|
            if item[:starred].nil?
                checked = 0
            else
                checked = 1
            end
            i = Item.first(id: item[:id])
            if i.nil?
                Item.create(name: item[:name], description: item[:description], starred: checked, due_date: item[:due_date], list: list, user: user,
                    created_at: Time.now, updated_at: Time.now)
            else
                i.name = item[:name]
                i.description = item[:description]
                i.starred = checked
                i.due_date = item[:due_date]
                i.updated_at = Time.now
                i.save
            end 
        end
        if list.valid?
            list.save
        end
    end

    def add_comment list, user, comments

        comments.each do |comment|
            comm = Comment.create(user_id: user.id, list_id: list.id, text: comment[:text])
            if comm.valid?
                comm.save
            end
        end
        list.save
    end

    def delete_list list_id, items
        list = List.first(id: list_id)
        permissions = list.permissions
        comments = list.comments
        items.each(&:destroy)
        permissions.each(&:destroy)
        comments.each(&:destroy)
        list.destroy
    end
end


