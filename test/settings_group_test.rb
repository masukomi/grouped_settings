#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../../../../test/test_helper'

#module SettingsDefaults
#  DEFAULTS = {:some_setting => 'foo'}
#end

class SettingsGroupTest < Test::Unit::TestCase
  
	def setup
		Settings.create(:var => 'test',           :value => 'foo'.to_yaml)
		Settings.create(:var => 'secondary_test', :value => 'bar'.to_yaml)
		test_group = SettingsGroup.create(:name=>'test_group')
		Settings.create(:var=>'grouped_var', :value=>'grouped_var_value', :settings_group_id=>test_group.id)
    	Settings.create(:var=>'grouped_var2', :value=>'grouped_var2_value', :settings_group_id=>test_group.id)
    	
    	
    	
	end
	
    def test_set
        #test updating
        #
        sg = SettingsGroup.find_by_name('test_group')
        sg.set('grouped_var', 'new_grouped_var_value')
        assert_equal 'new_grouped_var_value', Settings.get('grouped_var', 'test_group')
        #test creating
        #
        sg.set('new_grouped_var', 'value_of_new_grouped_var')
        assert_equal 'value_of_new_grouped_var', Settings.get('new_grouped_var', 'test_group')
        
        
    end
  
	def test_get
		sg = SettingsGroup.find_by_name('test_group')
		grouped_var = sg.get('grouped_var')
		assert_equal('grouped_var_value', grouped_var.value)
		
	end

	def test_get
		sg = SettingsGroup.find_by_name('test_group')
		assert sg.include?('grouped_var')
		assert ! sg.include?('test')
		
	end
end
