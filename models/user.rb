class User < Sequel::Model
    def_column_alias :username, :name

    def before_save
        super
        self.name = name.capitalize
    end

    set_primary_key :id

    one_to_many :items
    one_to_many :permissions
    one_to_many :logs

    def set_default_permissions
        Permi
    end

end
