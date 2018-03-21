class ApplicationRecord < ActiveRecord::Base
  require 'omniauth'  
  self.abstract_class = true
end