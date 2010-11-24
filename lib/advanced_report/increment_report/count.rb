class AdvancedReport::IncrementReport::Count < AdvancedReport::IncrementReport
  def name
    "Order Count"
  end

  def column
    "Count"
  end

  def description
    "Total number of completed orders"
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
      order_count = order_count(order)
      INCREMENTS.each { |type| data[type][date[type]][:value] += order_count }
      self.total += order_count
    end

    generate_ruport_data
  end
end
