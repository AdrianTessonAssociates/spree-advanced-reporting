class AdvancedReport
  attr_accessor :orders, :product_text, :date_text, :taxon_text, :ruportdata, :data, :params, :taxon, :product, :product_in_taxon

  def name
    "Base Advanced Report"
  end

  def description
    "Base Advanced Report"
  end

  def initialize(params)
    self.params = params
    self.data = {}
    self.ruportdata = {}
    search = Order.searchlogic(params[:search])
    search.checkout_complete = true
    search.state_does_not_equal('canceled')

    self.orders = search.find(:all)

    self.product_in_taxon = true
    if params[:advanced_reporting]
      if params[:advanced_reporting][:taxon_id] && params[:advanced_reporting][:taxon_id] != ''
        self.taxon = Taxon.find(params[:advanced_reporting][:taxon_id])
      end
      if params[:advanced_reporting][:product_id] && params[:advanced_reporting][:product_id] != ''
        self.product = Product.find(params[:advanced_reporting][:product_id])
      end  
    end
    if self.taxon && self.product && !self.product.taxons.include?(self.taxon)
      self.product_in_taxon = false
    end

    if self.product
      self.product_text = "Product: #{self.product.name}<br />"
    end
    if self.taxon
      self.taxon_text = "Taxon: #{self.taxon.name}<br />"
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

  def download_url(base, format, report_type = nil)
    elements = []
    params[:advanced_reporting] ||= {}
    params[:advanced_reporting]["report_type"] = report_type if report_type
    if params
      [:search, :advanced_reporting].each do |type|
        if params[type]
          params[type].each { |k, v| elements << "#{type}[#{k}]=#{v}" }
        end
      end
    end
    base + '.' + format + '?' + elements.join('&')
  end

  def revenue(order)
    rev = order.item_total
    if !self.product.nil? && product_in_taxon
      rev = order.line_items.select { |li| li.product == self.product }.inject(0) { |a, b| a += b.quantity * b.price }
    elsif !self.taxon.nil?
      rev = order.line_items.select { |li| li.product && li.product.taxons.include?(self.taxon) }.inject(0) { |a, b| a += b.quantity * b.price }
    end
    self.product_in_taxon ? rev : 0
  end

  def profit(order)
    profit = order.line_items.inject(0) { |profit, li| profit + (li.variant.price - li.variant.cost_price.to_f)*li.quantity }
    if !self.product.nil? && product_in_taxon
      profit = order.line_items.select { |li| li.product == self.product }.inject(0) { |profit, li| profit + (li.variant.price - li.variant.cost_price.to_f)*li.quantity }
    elsif !self.taxon.nil?
      profit = order.line_items.select { |li| li.product && li.product.taxons.include?(self.taxon) }.inject(0) { |profit, li| profit + (li.variant.price - li.variant.cost_price.to_f)*li.quantity }
    end
    self.product_in_taxon ? profit : 0
  end

  def units(order)
    units = order.line_items.sum(:quantity)
    if !self.product.nil? && product_in_taxon
      units = order.line_items.select { |li| li.product == self.product }.inject(0) { |a, b| a += b.quantity }
    elsif !self.taxon.nil?
      units = order.line_items.select { |li| li.product && li.product.taxons.include?(self.taxon) }.inject(0) { |a, b| a += b.quantity }
    end
    self.product_in_taxon ? units : 0
  end

  def order_count(order)
    self.product_in_taxon ? 1 : 0
  end
end
