class GeoUnits < AdvancedReport
  def description
    "Unit sales divided geographically, into states and countries"
  end

  def initialize(params)
    super(params)

    data = { :state => {}, :country => {} }
    orders.each do |order|
      units = order.line_items.sum(:quantity)
      if !self.product.nil? && product_in_taxon
        units = order.line_items.select { |li| li.product == self.product }.inject(0) { |a, b| a += b.quantity }
      elsif !self.taxon.nil?
        units = order.line_items.select { |li| li.product.taxons.include?(self.taxon) }.inject(0) { |a, b| a += b.quantity }
      end
      units = 0 if !self.product_in_taxon
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
