class Notifier < ActionMailer::Base
  default :from => "from@example.com"

  def order_received(order)
    @order = order

    mail :to => order.email, :subject => 'Pragmatic Store order confirmation'
  end

  def order_shiped(order)
    @order = order

    mail :to => order.email, :subject => 'Pragmatic Store order shipment information'
  end

  def error_occured(error)
    @error = error
    mail :to => "said.kaldybaev@gmail.com", :subject => "Store app error incident"
  end

end
