class Revenue < IncrementReport
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
      if params[:advanced_reporting] && params[:advanced_reporting][:product_id] && params[:advanced_reporting][:product_id] != ''
        rev = order.line_items.select { |li| li.product.id.to_s == params[:advanced_reporting][:product_id] }.inject(0) { |a, b| a += b.quantity * b.price }
      end
      INCREMENTS.each { |type| data[type][date[type]][:value] += rev }
      self.total += rev
    end

    INCREMENTS.each do |type|
      data[type].each { |k,v| ruportdata[type] << { "key" => k, "display" => v[:display], "value" => v[:value] } }
      ruportdata[type].sort_rows_by!(["key"])
      ruportdata[type].remove_column("key")
      ruportdata[type].replace_column("value") { |r| "$%0.2f" % r.value }
      ruportdata[type].rename_column("value", "Revenue")
      ruportdata[type].rename_column("display", dates[type][:header_display])
    end
  end
end
