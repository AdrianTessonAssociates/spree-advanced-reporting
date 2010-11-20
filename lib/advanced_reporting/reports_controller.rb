module AdvancedReporting::ReportsController
  def self.included(target)
    target.class_eval do
      alias :spree_index :index
      def index; advanced_reporting_index; end
      before_filter :basic_report_setup, :actions => [:revenue, :units, :top_products, :top_customers, :geo_revenue]
    end 
  end

  ADVANCED_REPORTS = {
      :revenue		=> { :name => "Revenue", :description => "Revenue" },
      :units		=> { :name => "Units", :description => "Units" },
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


  def revenue
    @report = Revenue.new(params)
    render :template => "admin/reports/base_report"

=begin
    respond_to do |format|
      format.html { render :template => "admin/reports/base_report" }
      format.pdf do
        #blah = [:daily, :weekly, :monthly].inject('') { |blah, type| blah += ruportdata[type].to_pdf } 
        #send_data blah, :type =>"application/pdf", :filename => "blah.pdf"
      end
      format.csv do
        send_data ruportdata[:weekly].to_csv, :type =>"application/csv", :filename => "blah.csv"
      end
    end
=end
  end

  def units
    @report = Units.new(params)
    render :template => "admin/reports/base_report"
  end

  def top_products
    @report = TopProducts.new(params, 4)
    render :template => "admin/reports/base_top_report"
  end

  def top_customers
    @report = TopCustomers.new(params, 4)
    render :template => "admin/reports/base_top_report"
  end

  def geo_revenue
    @report = GeoRevenue.new(params)
  end
end
