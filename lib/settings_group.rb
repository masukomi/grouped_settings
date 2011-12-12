class SettingsGroup < ActiveRecord::Base
	has_many :settings, :class_name=>"Settings" 
	#pluralization issue because Settings class should really be Setting
	#but isn't for historical reasons 
	
	def set(var_name, value)
    	setting = get(var_name)
    	if (! setting.nil?)
        	setting.value = value
        	setting.save
        else
            Settings.set(var_name, value, name)
        end
	end
	
	def get(var_name)
    	settings.each do |setting|
        	return setting if setting.var == var_name
    	end
    	return nil
	end
	
	def include?(var_name)
    	settings.each do |setting|
        	return true if setting.var == var_name
    	end
    	return false
	end
end

