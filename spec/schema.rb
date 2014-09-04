ActiveRecord::Schema.define do

  self.verbose = false

  create_table :people, :force => true do |t|
    t.string :name
  end

  create_table :accesses, :force => true do |t|
    t.string :token
  end

end