class WriteDefaultTranslations < ActiveRecord::Migration
  def self.up
    Page.find(:all).each do |page|
      %w(title breadcrumb slug keywords description).each do |attrib|
        page.send("#{attrib}=", page.read_attribute(attrib))
      end
      page.save
    end
    
    PagePart.find(:all).each  { |part|    part.content    = part.read_attribute(:content); part.save! }
    Snippet.find(:all).each   { |snippet| snippet.content = snippet.read_attribute(:content); snippet.save! }
  end

  def self.down
  end
end
