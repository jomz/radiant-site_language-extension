module I18nExt
  def with_locale(locale)
    used_locale = I18n.locale
    begin
      I18n.locale = locale.to_sym
      yield
    ensure
      I18n.locale = used_locale
    end
  end
end

I18n.extend(I18nExt)