class ApplicationModel < ActiveRecord::Base
  include I18nAble
  self.abstract_class = true
end