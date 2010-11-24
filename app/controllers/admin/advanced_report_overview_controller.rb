class Admin::AdvancedReportOverviewController < Admin::BaseController
  def index
    @reports = Admin::ReportsController::ADVANCED_REPORTS
    @products = Product.all
    @taxons = Taxon.all
    if defined?(MultiDomainExtension)
      @stores = Store.all
    end
    @report = AdvancedReport::IncrementReport::Revenue.new({ :search => {} })
    @top_products_report = AdvancedReport::TopReport::TopProducts.new({ :search => {} }, 5)
    @top_customers_report = AdvancedReport::TopReport::TopCustomers.new({ :search => {} }, 5)
    @top_customers_report.ruportdata.remove_column("Units")

    # From overview_dashboard, Cleanup eventually
    orders = Order.find(:all, :order => "completed_at DESC", :limit => 10, :include => :line_items, :conditions => "completed_at is not null")
    @last_orders = orders.inject([]) { |arr, o| arr << [o.name, o.line_items.sum(:quantity), o.total ]; arr }
    @best_taxons =  Taxon.connection.select_rows("select t.name, count(li.quantity) from line_items li inner join variants v on
           li.variant_id = v.id inner join products p on v.product_id = p.id inner join products_taxons pt on p.id = pt.product_id
           inner join taxons t on pt.taxon_id = t.id where t.taxonomy_id = #{Taxonomy.last.id} group by t.name order by count(li.quantity) desc limit 5;")
  end
end
