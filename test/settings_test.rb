#!/usr/bin/env ruby




require File.dirname(__FILE__) + '/../../../../test/test_helper'
require 'settings'

#AFTER the require instead of before so that we can make sure it works 
#even when this is loaded later than it should have been
module SettingsDefaults
    DEFAULTS = {
      :default_one 			=> 'default_one_value',
      :default_two          => 'default_two_value'
    }
end


class SettingsTest < Test::Unit::TestCase
  
	def setup
		Settings.create(:var => 'test',           :value => 'foo')
		Settings.create(:var => 'secondary_test', :value => 'bar')
		test_group = SettingsGroup.create(:name=>'test_group')
		Settings.create(:var=>'grouped_var', :value=>'grouped_var_value', :settings_group_id=>test_group.id)
	
	      
	
	end
	
#  def test_defaults
#    assert_equal 'foo', Settings.some_setting
#    assert_nil Settings.find(:first, :conditions => ['var = ?', 'some_setting'])
#    
#    Settings.some_setting = 'bar'
#    assert_equal 'bar', Settings.some_setting
#    assert_not_nil Settings.find(:first, :conditions => ['var = ?', 'some_setting'])
#  end
  
	def test_get

	    
	    #assert_equal 'default_one_value', Settings.default_one
	    assert_equal 'default_one_value', Settings.get('default_one')
	    assert_equal 'default_one_value', Settings.get(:default_one)
		#assert_equal 'foo', Settings.test
		assert_equal 'foo', Settings.get('test')
		assert_equal 'foo', Settings.get('test', nil)
		assert_equal 'foo', Settings.get(:test, nil)
		assert_equal 'foo', Settings.test(nil)
		
		#assert_equal 'bar', Settings.secondary_test
		#assert_equal 'bar', Settings[:secondary_test]
		#assert_equal 'bar', Settings['secondary_test']
		
		assert_equal nil, Settings.get(:grouped_var)
		#assert_equal nil, Settings.grouped_var
		assert_equal 'grouped_var_value', Settings.get('grouped_var', 'test_group')
		assert_equal 'grouped_var_value', Settings.get('grouped_var', :test_group)
		assert_equal 'grouped_var_value', Settings.get(:grouped_var, :test_group)
		assert_equal 'grouped_var_value', Settings.grouped_var('test_group')
		
	end
	
	def test_set
		assert_equal '321', Settings.test = '321'
		assert_equal '321', Settings.test
		assert_equal '322', Settings.set('test', '322', nil)
		assert_equal '322', Settings.test
		assert_equal '323', Settings.set(:test, '323', nil)
		assert_equal '323', Settings.test
		
		assert_equal '322', Settings.set('test', '322', :test_group)
		assert_equal '322', Settings.test(:test_group)
		assert_equal '323', Settings.set(:test, '323', :test_group)
		assert_equal '323', Settings.test(:test_group)
	
	end
	
  
  def test_complex_serialization
    object = [1, '2', {:three => true}]
    Settings.object = object
    assert_equal object, Settings.reload.object
  end
  
  def test_serialization_of_float
    Settings.float = 0.01
    Settings.reload
    assert_equal 0.01, Settings.float
    assert_equal 0.02, Settings.float * 2
  end
end
