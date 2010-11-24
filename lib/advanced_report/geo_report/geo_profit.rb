class AdvancedReport::GeoReport::GeoProfit < AdvancedReport::GeoReport
  def name
    "Profit by Geography"
  end

  def column
    "Profit"
  end

  def description
    "Profit divided geographically, into states and countries"
  end

  def initialize(params)
    super(params)

    data = { :state => {}, :country => {} }
    orders.each do |order|
      profit = profit(order)
      if order.bill_address.state
        data[:state][order.bill_address.state_id] ||= {
          :name => order.bill_address.state.name,
          :profit => 0
        }
        data[:state][order.bill_address.state_id][:profit] += profit
      end
      if order.bill_address.country
        data[:country][order.bill_address.country_id] ||= {
          :name => order.bill_address.country.name,
          :profit => 0
        }
        data[:country][order.bill_address.country_id][:profit] += profit
      end
    end

    [:state, :country].each do |type|
      ruportdata[type] = Table(%w[location Profit])
      data[type].each { |k, v| ruportdata[type] << { "location" => v[:name], "Profit" => v[:profit] } }
      ruportdata[type].sort_rows_by!(["location"])
      ruportdata[type].rename_column("location", type.to_s.capitalize)
      ruportdata[type].replace_column("Profit") { |r| "$%0.2f" % r.Profit }
    end
  end
end
