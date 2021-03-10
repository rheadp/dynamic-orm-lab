require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord


    def self.table_name
      self.to_s.downcase.pluralize
    end
    
    def self.column_names
      DB[:conn].results_as_hash = true
      DB[:conn]
      .execute("PRAGMA table_info('#{table_name}')")
      .map {|info| info['name']}
    end
  
    def self.find_by_name(name)
      DB[:conn].results_as_hash = true
      DB[:conn].execute("SELECT * FROM #{table_name} WHERE name = ?", name)
    end
  
    def self.find_by(hash)
      DB[:conn].results_as_hash = true
      condition = hash.map{|k,v| "#{k} = '#{v}'"}[0]
      DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{condition}")    
    end
  
    def table_name_for_insert
      self.class.table_name
    end
  
    def col_names_for_insert
      self.class.column_names.select{|s| s != "id"}.join(", ")
    end
  
    def values_for_insert
      self.class.column_names.map {|name| 
        value = self.send(name.to_s)
        "'#{value}'" if value
      }.compact.join(", ")
    end
  
    def save
      DB[:conn].execute("INSERT INTO #{table_name_for_insert}(#{col_names_for_insert}) VALUES(#{values_for_insert})" )
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end
  end