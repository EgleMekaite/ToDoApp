class Comment < Sequel::Model
    set_primary_key :id

    many_to_one :user
    many_to_one :list

    def validate
        super
        errors.add(:text, 'must contain a certain text') if !text || text.empty?
    end

    def before_save
        self.creation_date = Time.now
        self.creation_time = Time.now
    end

end