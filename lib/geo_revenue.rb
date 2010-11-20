class GeoRevenue < AdvancedReport
  def initialize(params)
    super(params)

    data = { :state => {}, :country => {} }
    orders.each do |order|
      rev = order.item_total
      units = order.line_items.sum(:quantity)
      if params[:advanced_reporting] && params[:advanced_reporting][:product_id] && params[:advanced_reporting][:product_id] != ''
        rev = order.line_items.select { |li| li.product.id.to_s == params[:advanced_reporting][:product_id] }.inject(0) { |a, b| a += b.quantity * b.price }
        units = order.line_items.select { |li| li.product.id.to_s == params[:advanced_reporting][:product_id] }.inject(0) { |a, b| a += b.quantity }
      end
      if order.bill_address.state
        data[:state][order.bill_address.state_id] ||= {
          :name => order.bill_address.state.name,
          :revenue => 0,
          :units => 0
        }
        data[:state][order.bill_address.state_id][:revenue] += rev
        data[:state][order.bill_address.state_id][:units] += units
      end
      if order.bill_address.country
        data[:country][order.bill_address.country_id] ||= {
          :name => order.bill_address.country.name,
          :revenue => 0,
          :units => 0
        }
        data[:country][order.bill_address.country_id][:revenue] += rev
        data[:country][order.bill_address.country_id][:units] += units
      end
    end

    [:state, :country].each do |type|
      ruportdata[type] = Table(%w[location Units Revenue])
      data[type].each { |k, v| ruportdata[type] << { "location" => v[:name], "Units" => v[:units], "Revenue" => v[:revenue] } }
      ruportdata[type].sort_rows_by!(["location"])
      ruportdata[type].rename_column("location", type.to_s.capitalize)
      ruportdata[type].replace_column("Revenue") { |r| "$%0.2f" % r.Revenue }
    end
  end
end
