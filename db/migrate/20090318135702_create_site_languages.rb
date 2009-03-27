class CreateSiteLanguages < ActiveRecord::Migration
  def self.up
    create_table :site_languages do |t|
      t.string 'code'
      t.string 'domain'
      t.column 'show_in_langnav', :boolean, :default => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :site_languages
  end
end
