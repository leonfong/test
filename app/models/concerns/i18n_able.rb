module I18nAble
  extend ActiveSupport::Concern

  included do
    def self.t(field=nil)
      if field
        I18n.t(field, scope: [
          :activerecord, :attributes, self.name.underscore.to_sym
        ])
      else
        I18n.t(self.name.underscore.to_sym, scope: [
          :activerecord, :attributes
        ])
      end
    end

    def t(field=nil)
      self.class.t(field)
    end

    def self.t_enum_by_value(val, field)
      tenum = I18n.t("#{field}_enum".to_sym, scope: [
        :activerecord, :attributes, self.name.underscore.to_sym
      ])
      return tenum unless tenum.is_a? Hash
      if val.nil?
        return tenum.fetch(:nil, nil)
      else
        return tenum.fetch(val.to_sym, tenum.fetch(:nil, nil))
      end
    end

    def t_enum(field)
      self.class.t_enum_by_value(self.send(field), field)
    end

    def t_enums(field)
      (self.send(field) || []).map do |v|
        self.class.t_enum_by_value(v, field)
      end
    end
  end
end

