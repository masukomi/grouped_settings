class <%= class_name %> < ActiveRecord::Migration
  def self.up
    create_table :settings, :force => true do |t|
        t.column :var, :string, :null => false
        t.column :value, :string, :null => true
		t.column :settings_group_id, :integer, :null => true
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
    end
	create_table :settings_groups, :force => true do |t|
		t.column :name, :string, :null => false
	end
  end

  def self.down
    drop_table :settings
	drop_table :settings_groups
  end
end
