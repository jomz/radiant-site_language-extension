class CreateTranslationTables < ActiveRecord::Migration
  def self.up
    Page.create_translation_table! :title => :string, :breadcrumb => :string, :slug => :string, :keywords => :string, :description => :string
    PagePart.create_translation_table! :content => :text
    Snippet.create_translation_table! :content => :text
  end

  def self.down
    Page.drop_translation_table!
    PagePart.drop_translation_table!
    Snippet.drop_translation_table!
  end
end
