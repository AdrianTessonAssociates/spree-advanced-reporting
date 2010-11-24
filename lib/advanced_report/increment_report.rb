class AdvancedReport::IncrementReport < AdvancedReport
  INCREMENTS = [:daily, :weekly, :monthly, :yearly]
  attr_accessor :increments, :dates, :total, :all_data

  def initialize(params)
    super(params)
  
    self.increments = INCREMENTS 
    self.ruportdata = INCREMENTS.inject({}) { |h, inc| h[inc] = Table(%w[key display value]); h }
    self.data = INCREMENTS.inject({}) { |h, inc| h[inc] = {}; h }

    self.dates = {
      :daily => {
        :date_hash => "%F",
        :date_display => "%m-%d-%Y",
        :header_display => 'Daily',
        :timestamp => "%Y-%m-%d"
      },
      :weekly => {
        :date_hash => "%U",
        :date_display => "%F",
        :header_display => 'Weekly'
      },
      :monthly => {
        :date_hash => "%Y-%m",
        :date_display => "%B %Y",
        :header_display => 'Monthly',
        :timestamp => "%Y-%m-01"
      },
      :yearly => {
        :date_hash => "%Y",
        :date_display => "%Y",
        :header_display => 'Yearly',
        :timestamp => "%Y-01-01"
      }
    }
  end

  def generate_ruport_data
    self.all_data = Table(%w[increment key display value]) 
    INCREMENTS.each do |inc|
      data[inc].each { |k,v| ruportdata[inc] << { "key" => k, "display" => v[:display], "value" => v[:value] } }
      ruportdata[inc].data.each do |p|
        self.all_data << { "increment" => inc.to_s.capitalize, "key" => p.data["key"], "display" => p.data["display"], "value" => p.data["value"] }
      end
      ruportdata[inc].sort_rows_by!(["key"])
      ruportdata[inc].remove_column("key")
      ruportdata[inc].rename_column("display", dates[inc][:header_display])
      ruportdata[inc].rename_column("value", self.class.name.split('::').last)
    end
    self.all_data.sort_rows_by!(["key"])
    self.all_data.remove_column("key")
    self.all_data = Grouping(self.all_data, :by => "increment") 
  end

  def get_week_display(time)
    d = Date.parse(time.strftime("%F"))
    d -= 1 while Date::DAYNAMES[d.wday] != 'Sunday'
    "#{d.strftime("%m-%d-%Y")} - #{(d+6).strftime("%m-%d-%Y")}"
  end

  def get_prior_sunday(time)
    d = Date.parse(time.strftime("%F"))
    d -= 1 while Date::DAYNAMES[d.wday] != 'Sunday'
    d.to_time.to_i
  end

  def format_total
    self.total 
  end
end
