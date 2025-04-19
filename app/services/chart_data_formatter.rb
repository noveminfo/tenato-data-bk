class ChartDataFormatter
  class << self
    def format_time_series(data, options = {})
      {
        labels: data.keys,
        datasets: [{
          label: options[:label] || 'Value',
          data: data.values,
          fill: options[:fill] || false
        }]
      }
    end

    def format_pie_chart(data, options = {})
      {
        labels: data.keys,
        datasets: [{
          data: data.values,
          backgroundColor: generate_colors(data.length)
        }]
      }
    end

    def format_bar_chart(data, options = {})
      {
        labels: data.keys,
        datasets: [{
          label: options[:label] || 'Value',
          data: data.values,
          backgroundColor: options[:backgroundColor] || '#4CAF50'
        }]
      }
    end

    private

    def generate_colors(count)
      # 基本的なカラーパレット
      colors = [
        '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF',
        '#FF9F40', '#FF6384', '#C9CBCF', '#4CAF50', '#03A9F4'
      ]
      
      # 必要な数だけ色を生成
      colors.cycle.take(count).to_a
    end
  end
end
