class OrdersController < ApplicationController

  def index
    @orders = Order.paginate :page => params[:page], :order => "created_at desc", :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @orders }
    end
  end

  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @order }
    end
  end

  def new
    if current_cart.line_items.empty?
      redirect_to store_url, :notice => "Your cart is empty!"
      return
    end

    @order = Order.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @order }
    end
  end

  def edit
    @order = Order.find(params[:id])
  end

  def create
    @order = Order.new(params[:order])
    @order.add_line_items_from_cart(current_cart)

    respond_to do |format|
      if @order.save
        Cart.destroy(session[:cart_id])
        session[:cart_id] = nil
        Notifier.order_received(@order).deliver
        format.html { redirect_to(store_url, :notice => 'Thanks for your order!.') }
        format.xml { render :xml => @order, :status => :created, :location => @order }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update_attributes(params[:order])
        Notifier.order_shiped(@order).deliver unless @order.ship_date.nil?
        format.html { redirect_to(@order, :notice => 'Order was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @order = Order.find(params[:id])
    Notifier.order_deleted(@order).deliver
    @order.destroy

    respond_to do |format|
      format.html { redirect_to(orders_url) }
      format.xml { head :ok }
    end
  end
end
