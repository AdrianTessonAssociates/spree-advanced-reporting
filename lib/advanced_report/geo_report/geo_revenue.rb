class AdvancedReport::GeoReport::GeoRevenue < AdvancedReport::GeoReport
  def name
    "Revenue by Geography"
  end

  def column
    "Revenue"
  end

  def description
    "Revenue divided geographically, into states and countries"
  end

  def initialize(params)
    super(params)

    data = { :state => {}, :country => {} }
    orders.each do |order|
      revenue = revenue(order)
      if order.bill_address.state
        data[:state][order.bill_address.state_id] ||= {
          :name => order.bill_address.state.name,
          :revenue => 0
        }
        data[:state][order.bill_address.state_id][:revenue] += revenue
      end
      if order.bill_address.country
        data[:country][order.bill_address.country_id] ||= {
          :name => order.bill_address.country.name,
          :revenue => 0
        }
        data[:country][order.bill_address.country_id][:revenue] += revenue
      end
    end

    [:state, :country].each do |type|
      ruportdata[type] = Table(%w[location Revenue])
      data[type].each { |k, v| ruportdata[type] << { "location" => v[:name], "Revenue" => v[:revenue] } }
      ruportdata[type].sort_rows_by!(["location"])
      ruportdata[type].rename_column("location", type.to_s.capitalize)
      ruportdata[type].replace_column("Revenue") { |r| "$%0.2f" % r.Revenue }
    end
  end
end
