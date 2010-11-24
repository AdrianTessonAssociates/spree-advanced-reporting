module AdvancedReporting::ReportsController
  def self.included(target)
    target.class_eval do
      alias :spree_index :index
      def index; advanced_reporting_index; end
      before_filter :basic_report_setup, :actions => [:profit, :revenue, :units, :top_products, :top_customers, :geo_revenue, :geo_units, :count]
    end 
  end

  ADVANCED_REPORTS = {
      :revenue		=> { :name => "Revenue", :description => "Revenue" },
      :units		=> { :name => "Units", :description => "Units" },
      :profit		=> { :name => "Profit", :description => "Profit" },
      :count		=> { :name => "Order Count", :description => "Order Count" },
      :top_products	=> { :name => "Top Products", :description => "Top Products" },
      :top_customers	=> { :name => "Top Customers", :description => "Top Customers" },
      :geo_revenue	=> { :name => "Geo Revenue", :description => "Geo Revenue" },
      :geo_units	=> { :name => "Geo Units", :description => "Geo Units" },
      :geo_profit	=> { :name => "Geo Profit", :description => "Geo Profit" },
  }

  def advanced_reporting_index
    @reports = ADVANCED_REPORTS.merge(Admin::ReportsController::AVAILABLE_REPORTS)
  end

  def basic_report_setup
    @reports = ADVANCED_REPORTS
    @products = Product.all
    @taxons = Taxon.all
    if defined?(MultiDomainExtension)
      @stores = Store.all
    end
  end

  def geo_report_render(filename)
    params[:advanced_reporting] ||= {}
    params[:advanced_reporting]["report_type"] = params[:advanced_reporting]["report_type"].to_sym if params[:advanced_reporting]["report_type"]
    params[:advanced_reporting]["report_type"] ||= :state
    respond_to do |format|
      format.html { render :template => "admin/reports/geo_base" }
      format.pdf do
        send_data @report.ruportdata[params[:advanced_reporting]['report_type']].to_pdf, :type =>"application/pdf", :filename => "#{filename}.pdf"
      end
      format.csv do
        send_data @report.ruportdata[params[:advanced_reporting]['report_type']].to_csv, :type =>"application/csv", :filename => "#{filename}.csv"
      end
    end
  end

  def base_report_top_render(filename)
    respond_to do |format|
      format.html { render :template => "admin/reports/top_base" }
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
      format.html { render :template => "admin/reports/increment_base" }
      format.pdf do
        if params[:advanced_reporting]["report_type"] == :all
          send_data @report.all_data.to_pdf, :type =>"application/pdf", :filename => filename + ".pdf"
        else 
          send_data @report.ruportdata[params[:advanced_reporting]['report_type']].to_pdf, :type =>"application/pdf", :filename => filename + ".pdf"
        end 
      end
      format.csv do
        if params[:advanced_reporting]["report_type"] == :all
          send_data @report.all_data.to_csv, :type =>"application/csv", :filename => filename + ".csv"
        else 
          send_data @report.ruportdata[params[:advanced_reporting]['report_type']].to_csv, :type =>"application/csv", :filename => filename + ".csv"
        end
      end
      #format.svg do
      #  if params[:advanced_reporting]["report_type"] == :all
      #    send_data @report.all_data.to_svg, :type =>"application/svg", :filename => filename + ".svg"
      #  else 
      #    send_data @report.ruportdata[params[:advanced_reporting]['report_type']].to_svg, :type =>"application/svg", :filename => filename + ".svg"
      #  end
      #end
    end
  end

  def revenue
    @report = AdvancedReport::IncrementReport::Revenue.new(params)
    base_report_render("revenue")
  end

  def units
    @report = AdvancedReport::IncrementReport::Units.new(params)
    base_report_render("units")
  end

  def profit
    @report = AdvancedReport::IncrementReport::Profit.new(params)
    base_report_render("profit")
  end

  def count
    @report = AdvancedReport::IncrementReport::Count.new(params)
    base_report_render("profit")
  end

  def top_products
    @report = AdvancedReport::TopReport::TopProducts.new(params, 4)
    base_report_top_render("top_products")
  end

  def top_customers
    @report = AdvancedReport::TopReport::TopCustomers.new(params, 4)
    base_report_top_render("top_customers")
  end

  def geo_revenue
    @report = AdvancedReport::GeoReport::GeoRevenue.new(params)
    geo_report_render("geo_revenue")
  end

  def geo_units
    @report = AdvancedReport::GeoReport::GeoUnits.new(params)
    geo_report_render("geo_units")
  end

  def geo_profit
    @report = AdvancedReport::GeoReport::GeoProfit.new(params)
    geo_report_render("geo_profit")
  end
end
