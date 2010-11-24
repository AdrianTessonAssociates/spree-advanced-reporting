class AdvancedReport::IncrementReport::Revenue < AdvancedReport::IncrementReport
  def name
    "Revenue"
  end

  def column
    "Revenue"
  end

  def description
    "Total order revenue, where revenue is the sum of order item prices, excluding shipping and tax"
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
      rev = order.item_total
      if !self.product.nil? && product_in_taxon
        rev = order.line_items.select { |li| li.product == self.product }.inject(0) { |a, b| a += b.quantity * b.price }
      elsif !self.taxon.nil?
        rev = order.line_items.select { |li| li.product && li.product.taxons.include?(self.taxon) }.inject(0) { |a, b| a += b.quantity * b.price }
      end
      rev = 0 if !self.product_in_taxon
      INCREMENTS.each { |type| data[type][date[type]][:value] += rev }
      self.total += rev
    end

    generate_ruport_data

    INCREMENTS.each { |type| ruportdata[type].replace_column("Revenue") { |r| "$%0.2f" % r["Revenue"] } }
  end

  def format_total
    '$' + ((self.total*100).round.to_f / 100).to_s
  end
end
