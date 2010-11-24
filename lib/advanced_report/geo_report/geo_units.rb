class AdvancedReport::GeoReport::GeoUnits < AdvancedReport::GeoReport
  def name
    "Units Sold by Geography"
  end

  def column
    "Units"
  end

  def description
    "Unit sales divided geographically, into states and countries"
  end

  def initialize(params)
    super(params)

    data = { :state => {}, :country => {} }
    orders.each do |order|
      units = units(order)
      if order.bill_address.state
        data[:state][order.bill_address.state_id] ||= {
          :name => order.bill_address.state.name,
          :units => 0
        }
        data[:state][order.bill_address.state_id][:units] += units
      end
      if order.bill_address.country
        data[:country][order.bill_address.country_id] ||= {
          :name => order.bill_address.country.name,
          :units => 0
        }
        data[:country][order.bill_address.country_id][:units] += units
      end
    end

    [:state, :country].each do |type|
      ruportdata[type] = Table(%w[location Units])
      data[type].each { |k, v| ruportdata[type] << { "location" => v[:name], "Units" => v[:units] } }
      ruportdata[type].sort_rows_by!(["location"])
      ruportdata[type].rename_column("location", type.to_s.capitalize)
    end
  end
end
