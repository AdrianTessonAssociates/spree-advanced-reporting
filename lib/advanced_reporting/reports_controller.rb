module AdvancedReporting::ReportsController
  def self.included(target)
    target.class_eval do
      alias :spree_index :index
      def index; advanced_reporting_index; end
      before_filter :basic_report_setup, :actions => [:profit, :revenue, :units, :top_products, :top_customers, :geo_revenue]
    end 
  end

  ADVANCED_REPORTS = {
      :revenue		=> { :name => "Revenue", :description => "Revenue" },
      :units		=> { :name => "Units", :description => "Units" },
      :profit		=> { :name => "Profit", :description => "Profit" },
      :top_products	=> { :name => "Top Products", :description => "Top Products" },
      :top_customers	=> { :name => "Top Customers", :description => "Top Customers" },
      :geo_revenue	=> { :name => "Geo Revenue", :description => "Geo Revenue" },
  }

  def advanced_reporting_index
    @reports = ADVANCED_REPORTS.merge(Admin::ReportsController::AVAILABLE_REPORTS)
  end

  def basic_report_setup
    @reports = ADVANCED_REPORTS
    @products = Product.all 
    if defined?(MultiDomainExtension)
      @stores = Store.all
      # TODO: Add UI for limiting products / store on frontend
    end
    @report_name = params[:action].gsub(/_/, ' ').split(' ').each { |w| w.capitalize! }.join(' ')
  end

  def base_report_top_render(filename)
    respond_to do |format|
      format.html { render :template => "admin/reports/base_top_report" }
      format.pdf do
        send_data @report.ruportdata.to_pdf, :type =>"application/pdf", :filename => "#{filename}.pdf"
      end
      format.csv do
        send_data @report.ruportdata.to_csv, :type =>"application/csv", :filename => "#{filename}.csv"
      end
    end
  end

  def base_report_render(filename)
    params[:advanced_reporting] ||= {}
    params[:advanced_reporting]["report_type"] = params[:advanced_reporting]["report_type"].to_sym if params[:advanced_reporting]["report_type"]
    params[:advanced_reporting]["report_type"] ||= :daily
    respond_to do |format|
      format.html { render :template => "admin/reports/base_report" }
      format.pdf do
        send_data @report.ruportdata[params[:advanced_reporting]['report_type']].to_pdf, :type =>"application/pdf", :filename => filename + ".pdf"
      end
      format.csv do
        send_data @report.ruportdata[params[:advanced_reporting]['report_type']].to_csv, :type =>"application/csv", :filename => filename + ".csv"
      end
    end
  end

  def revenue
    @report = Revenue.new(params)
    base_report_render("revenue")
  end

  def units
    @report = Units.new(params)
    base_report_render("units")
  end

  def profit
    @report = Profit.new(params)
    base_report_render("profit")
  end

  def top_products
    @report = TopProducts.new(params, 4)
    base_report_top_render("top_products")
  end

  def top_customers
    @report = TopCustomers.new(params, 4)
    base_report_top_render("top_customers")
  end

  def geo_revenue
    @report = GeoRevenue.new(params)
  end
end
