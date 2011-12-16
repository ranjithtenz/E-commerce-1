class PaymentType < ActiveRecord::Base
  def self.names
    all.collect {|p| p.name }
  end
end
