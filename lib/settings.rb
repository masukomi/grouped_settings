class Settings < ActiveRecord::Base
	belongs_to :settings_group
	@@defaults			= nil	
	class SettingNotFound < RuntimeError; end
	
	#get or set a variable with the variable as the called method
	def self.method_missing(method, *args)
		method_name = method.to_s
		
		if method_name.include? '='
			#set a value for a variable
			group_name = nil
			var_name = method_name.gsub('=', '')
			value = args.first
			#self[var_name] = value
			self.set(var_name, value, group_name )
			
		else
			#retrieve a value
			#self[method_name]
			group_name = defined?(args[0]) ? args[0] : nil
			self.get(method_name, group_name)
		end
	end
	
	#destroy the specified settings record
	def self.destroy(var_name, group_name = nil)
		var_name = symbol_or_other_to_s(var_name)
		group_name = group_name.to_s if (group_name != nil)
		var = self.get(var_name, group_name)
		if ! var.nil?
			var.destroy
			return true
		else
			raise SettingNotFound, "Setting variable \"#{var_name}\" not found"
		end
	end

	#retrieve all settings as a hash
	def self.all
		vars = find(:all, :select => 'var, value', :include=>[:settings_group])
		
		result = {}
		vars.each do |record|
			result[record.var] = YAML::load(record.value)
		end
		result.with_indifferent_access
	end
	
	#reload all settings from the db
	def self.reload # :nodoc:
		self # deprecated, no longer needed since caching is not used.
	end
	
	#retrieve a setting value bar [] notation
#	def self.[](var_name)
#		#retrieve a setting
#		var_name = symbol_or_other_to_s(var_name)
#		
#		if var = find(:first, :conditions => ['var = ?', var_name])
#			YAML::load(var.value)
#		elsif @@defaults[var_name]
#			@@defaults[var_name]
#		else
#			nil
#		end
#	end
	
	def self.get(var_name, group_name = nil)
	    if (@@defaults == nil)
	       @@defaults = (defined?(SettingsDefaults) ? SettingsDefaults::DEFAULTS : {}).with_indifferent_access
	    end
		var_name = symbol_or_other_to_s(var_name)
		group_name = determine_group_name(group_name)
		var = get_record(var_name, group_name) 
		if var
			return var.value #YAML::load(var.value)
		elsif @@defaults[var_name]
			@@defaults[var_name]
		else
			nil
		end
	end

	def self.set(var_name, value, group_name = nil)
		var_name = symbol_or_other_to_s(var_name)
		group_name = determine_group_name(group_name)

		record = get_record(var_name, group_name)
		
		if (record.nil? || record.value != value)
			var_name = symbol_or_other_to_s(var_name)
				if (record.nil?)
					record = Settings.new(:var => var_name, :settings_group_id=> (group_name.nil? ? nil : SettingsGroup.find_or_create_by_name(group_name).id))
				end
				record.value = value# = value.to_yaml
				record.save
		end
		return value
	end
	
	def value=(new_value)
    	write_attribute('value', new_value.to_yaml)
	end
#	def set(new_value)
#    	value = new_value.to_yaml
#	end
	
	def value
    	base_value = read_attribute('value')
    	#
    	if ! base_value.nil?
         	return YAML::load(base_value)
        end
        return nil
	end
	
	#set a setting value by [] notation
#	def self.[]=(var_name, value)
#		if self[var_name] != value
#			var_name = symbol_or_other_to_s(var_name)
#			
#			record = Settings.find(:first, :conditions => ['var = ?', var_name]) || Settings.new(:var => var_name)
#			record.value = value.to_yaml
#			record.save
#		end
#	end

	private 
	def self.determine_group_name(object)
		if (object != nil)
			if (! object.instance_of?(SettingsGroup))
				return symbol_or_other_to_s(object) 
			else
				return group_name.name 
			end
		end
		return nil
	end

	def self.symbol_or_other_to_s(object)
		if (! object.instance_of?(Symbol))
			return object.to_s
		else
			return object.id2name
		end
		
	end

	def self.get_record(var_name, group_name)
		if (group_name.nil?)
			return find(:first, :conditions => ['var = ? AND settings_group_id is NULL', var_name])
		else
			return find(:first, :include=>[:settings_group], :conditions => ['var = ? AND settings_groups.name = ?', var_name, group_name])
		end
	end

	
end
