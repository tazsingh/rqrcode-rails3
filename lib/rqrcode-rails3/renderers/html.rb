module RQRCode
  module Renderers
    class Html
      class << self
        # Render the HTML table from the qrcode string provided from the RQRCode gem
        #   Options:
        #   offset - Padding around the QR Code (e.g. 10, Default: 0)
        #   unit   - How many pixels per module (Default: 4)
        #   fill   - Background color (e.g "ffffff")
        #   color  - Foreground color for the code (e.g. "000000")

        def render(qrcode, options={})
          offset  = options[:offset].to_i || 0
          color   = options[:color]       || "000"
          unit    = options[:unit]        || 4
          fill    = options[:fill]        || 'fff'

          # height and width dependent on offset and QR complexity
          dimension = (qrcode.module_count*unit) + (2*offset)

          open_tag  = %{<table style="width:#{dimension}px; height:#{dimension}px; background-color:##{fill}; border-collapse:collapse; border-spacing: 0;">}
          close_tag = "</table>"

          result = []
          qrcode.modules.each_index do |c|
            tmp = []
            qrcode.modules.each_index do |r|
              y = c*unit + offset
              x = r*unit + offset

              # next unless qrcode.is_dark(c, r)
              if qrcode.is_dark(c, r)
                tmp << %{<td style="background-color:##{color};"/>}
              else
                tmp << %{<td/>}
              end
            end
            result << "<tr>#{tmp.join "\n"}</tr>"
          end

          table = [open_tag, result, close_tag].flatten.join("\n")
        end
      end
    end
  end
end
