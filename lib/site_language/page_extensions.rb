module SiteLanguage::PageExtensions
  
  def self.included(base)
    base.class_eval do
      #def find_by_url(url, live = true, clean = true)
      #  return nil if virtual?
      #  url = clean_url(url) if clean
      #  my_url = self.url
      #  if (my_url == url) && (not live or published?)
      #    self
      #  elsif (url =~ /^#{Regexp.quote(my_url)}([^\/]*)/)
      #    slug_child = children.find_by_slug($1)
      #    if slug_child
      #      found = slug_child.find_by_url(url, live, clean)
      #      return found if found
      #    end
      #    children.each do |child|
      #      found = child.find_by_url(url, live, clean)
      #      return found if found
      #    end
      #    file_not_found_types = ([FileNotFoundPage] + FileNotFoundPage.descendants)
      #    file_not_found_names = file_not_found_types.collect { |x| x.name }
      #    condition = (['class_name = ?'] * file_not_found_names.length).join(' or ')
      #    condition = "status_id = #{Status[I18n.t('status.published').to_sym].id} and (#{condition})" if live
      #    children.find(:first, :conditions => [condition] + file_not_found_names)
      #  end
      #end
      
      #def published?
      #  status == Status[I18n.t('status.published').to_sym]
      #end
      
      def save_page_parts
        if @page_parts
          parts_to_be_saved = []
          @page_parts.each do |p|
            p.save!
            old_part = self.parts_without_pending.select{|op| op.name == p.name}.first
            if old_part
              PagePartTranslation.find_all_by_page_part_id(old_part.id).each do |transl|
                transl.update_attributes(:page_part_id => p.id) unless transl.locale.to_sym == I18n.locale
              end
            end
            parts_to_be_saved << p
          end
          self.parts_without_pending.clear
          parts_to_be_saved.each {|part| self.parts_without_pending << part }
        end
        @page_parts = nil
        true
      end 
      
      def set_required_fields_from_default
        %w(slug title breadcrumb).each do |key|
          self.send("#{key}=", self.read_attribute(key))
        end
        save!
      end
    end
  end
  
  def translated_url(langcode)
    cur_lang = I18n.locale.to_s
    if self.class_name.eql?("RailsPage") # (from the share_layouts extension)
      r = "/#{langcode}/#{self.url[3..-1]}"
    else
      I18n.locale = langcode
      r = "/#{langcode}#{url}"
      I18n.locale = cur_lang
    end
    r
  end
  
  def translated_slug(langcode)
    cur_lang = I18n.locale
    I18n.locale = langcode
    r = slug
    I18n.locale = cur_lang
    r
  end
  
end