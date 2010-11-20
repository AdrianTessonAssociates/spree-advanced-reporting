class TopCustomers < TopReport
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
        if params[:advanced_reporting] && params[:advanced_reporting][:product_id] && params[:advanced_reporting][:product_id] != ''
          rev = order.line_items.select { |li| li.product.id.to_s == params[:advanced_reporting][:product_id] }.inject(0) { |a, b| a += b.quantity * b.price }
          units = order.line_items.select { |li| li.product.id.to_s == params[:advanced_reporting][:product_id] }.inject(0) { |a, b| a += b.quantity }
        end
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
