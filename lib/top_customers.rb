class TopCustomers < TopReport
  def description
    "Top selling customers, calculated by revenue"
  end

  def initialize(params, limit)
    super(params)

    orders.each do |order|
      if order.user
        data[order.user.id] ||= {
          :email => order.user.email,
          :revenue => 0,
          :units => 0
        }
        # check this
        rev = order.item_total
        units = order.line_items.sum(:quantity)
        if !self.product.nil? && product_in_taxon
          rev = order.line_items.select { |li| li.product == self.product }.inject(0) { |a, b| a += b.quantity * b.price }
          units = order.line_items.select { |li| li.product == self.product }.inject(0) { |a, b| a += b.quantity }
        elsif !self.taxon.nil?
          rev = order.line_items.select { |li| li.product.taxons.include?(self.taxon) }.inject(0) { |a, b| a += b.quantity * b.price }
          units = order.line_items.select { |li| li.product.taxons.include?(self.taxon) }.inject(0) { |a, b| a += b.quantity }
        end
        rev = units = 0 if !self.product_in_taxon
        data[order.user.id][:revenue] += rev
        data[order.user.id][:units] += units
      end
    end

    self.ruportdata = Table(%w[email Units Revenue])
    data.inject({}) { |h, (k, v) | h[k] = v[:revenue]; h }.sort { |a, b| a[1] <=> b [1] }.reverse[0..4].each do |k, v|
      ruportdata << { "email" => data[k][:email], "Units" => data[k][:units], "Revenue" => data[k][:revenue] } 
    end
    ruportdata.replace_column("Revenue") { |r| "$%0.2f" % r.Revenue }
    ruportdata.rename_column("email", "Customer Email")
  end
end
