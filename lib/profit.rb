class Profit < IncrementReport
  def description
    "Total profit in orders, where profit is the sum of item quantity times item price minus item cost price"
  end

  def initialize(params)
    super(params)
    self.total = 0
    self.orders.each do |order|
      date = {}
      INCREMENTS.each do |type|
        date[type] = order.completed_at.strftime(dates[type][:date_hash])
        data[type][date[type]] ||= {
          :value => 0, 
          :display => type == :weekly ? get_week_display(order.completed_at) : order.completed_at.strftime(dates[type][:date_display]),
          :timestamp => type == :weekly ? get_prior_sunday(order.completed_at).to_i :
             Time.parse(order.completed_at.strftime(dates[type][:timestamp])).to_i
        }
      end
      profit = order.line_items.inject(0) { |profit, li| profit + (li.variant.price - li.variant.cost_price)*li.quantity }
      if !self.product.nil? && product_in_taxon
        profit = order.line_items.select { |li| li.product == self.product }.inject(0) { |profit, li| profit + (li.variant.price - li.variant.cost_price)*li.quantity }
      elsif !self.taxon.nil?
        profit = order.line_items.select { |li| li.product && li.product.taxons.include?(self.taxon) }.inject(0) { |profit, li| profit + (li.variant.price - li.variant.cost_price)*li.quantity }
      end
      profit = 0 if !self.product_in_taxon
      INCREMENTS.each { |type| data[type][date[type]][:value] += profit }
      self.total += profit
    end

    generate_ruport_data

    INCREMENTS.each { |type| ruportdata[type].replace_column("Profit") { |r| "$%0.2f" % r["Profit"] } }
  end
end
