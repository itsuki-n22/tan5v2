class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true 

  def joined_error_message
    errors.messages.to_a.join('')
  end
end
