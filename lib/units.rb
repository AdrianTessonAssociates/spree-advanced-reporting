class Units < IncrementReport
  def description
    "Total units sold in orders, a sum of the item quantities per order or per item"
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
      units = order.line_items.sum(:quantity)
      if !self.product.nil? && product_in_taxon
        units = order.line_items.select { |li| li.product == self.product }.inject(0) { |a, b| a += b.quantity }
      elsif !self.taxon.nil?
        units = order.line_items.select { |li| li.product.taxons.include?(self.taxon) }.inject(0) { |a, b| a += b.quantity }
      end
      units = 0 if !self.product_in_taxon
      INCREMENTS.each { |type| data[type][date[type]][:value] += units }
      self.total += units
    end

    generate_ruport_data
  end
end
