class User < Sequel::Model
    def_column_alias :username, :name

    set_primary_key :id

    one_to_many :items
    one_to_many :permissions
    one_to_many :logs
    one_to_many :comments

    attr_accessor :new_password

    def before_validation
      self.created_at = Time.now
    end

    def before_save
      if new_password
        self.password = Digest::MD5.hexdigest new_password
      end
    end

    def validate
      super
      validates_presence [:name, :created_at], message: 'please enter a username'
      validates_format /\A[A-Za-z]/, :name, message: 'please use letters to create your username'
      validates_min_length 4, :name, message: 'username should be at least 4 characters long'
      validates_unique :name, message: 'this username is already taken'

      if new_password
        validates_min_length 4, :new_password, message: 'Password should be at least 4 characters long'
      end
    end

    def self.find_by_login name, password
      md5sum = Digest::MD5.hexdigest password
      User.first(name: name, password: md5sum)
    end
end
