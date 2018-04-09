class User < Sequel::Model
    def_column_alias :username, :name

    set_primary_key :id

    one_to_many :items
    one_to_many :permissions
    one_to_many :logs
    one_to_many :comments

    def validate
      super
      errors.add(:name, 'cannot be blank') if !name || name.empty?
      errors.add(:name, 'already exists') if name && new? && User[:name=>name]
      errors.add(:password, 'cannot be blank') if !password || password.empty?
      errors.add(:name, 'not a valid name') unless name =~ /\A[A-Za-z]/
    end

    def before_create
      self.created_at = Time.now
    end

end
