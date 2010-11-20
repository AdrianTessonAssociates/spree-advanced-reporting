class AdvancedReport
  attr_accessor :orders, :product_text, :date_text, :ruportdata, :data

  def initialize(params)
    self.data = {}
    self.ruportdata = {}
    search = Order.searchlogic(params[:search])
    search.checkout_complete = true

    self.orders = search.find(:all)
    if params[:advanced_reporting] && params[:advanced_reporting][:product_id] && params[:advanced_reporting][:product_id] != ''
      product = Product.find(params[:advanced_reporting][:product_id])
      self.product_text = "Product: #{product.name}<br />" if product
    end
    self.date_text = "Date Range:"
    if params[:search]
      if params[:search][:created_at_after] != '' && params[:search][:created_at_before] != ''
        self.date_text += " From #{params[:search][:created_at_after]} to #{params[:search][:created_at_before]}"
      elsif params[:search][:created_at_after] != ''
        self.date_text += " After #{params[:search][:created_at_after]}"
      elsif params[:search][:created_at_before] != ''
        self.date_text += " Before #{params[:search][:created_at_after]}"
      else
        self.date_text += " All"
      end
    else
      self.date_text += " All"
    end
  end
end
