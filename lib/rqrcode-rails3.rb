require 'action_controller'
require 'rqrcode'
require 'rqrcode-rails3/size_calculator.rb'
require 'rqrcode-rails3/renderers/svg.rb'
require 'rqrcode-rails3/renderers/html.rb'

module RQRCode
  Mime::Type.register "image/svg+xml", :svg  unless Mime::Type.lookup_by_extension(:svg)
  Mime::Type.register "image/png",     :png  unless Mime::Type.lookup_by_extension(:png)
	Mime::Type.register "image/jpeg",    :jpeg unless Mime::Type.lookup_by_extension(:jpeg)
  Mime::Type.register "image/gif",     :gif  unless Mime::Type.lookup_by_extension(:gif)

  extend SizeCalculator

  ActionController::Renderers.add :qrcode do |rqrcode_object, options|
    format = self.request.format.symbol

    svg = if rqrcode_object.is_a? RQRCode::QRCode
      RQRCode::Renderers::SVG::render rqrcode_object
    else
      size   = options[:size]  || RQRCode.minimum_qr_size_from_string(string)
      level  = options[:level] || :h

      qrcode = RQRCode::QRCode.new(string, :size => size, :level => level)
      RQRCode::Renderers::SVG::render qrcode, options
    end

    data = if format && format == :svg
      svg
    else
      # This is what MiniMagick::Image.read does under the hood but with `validate` set to `true` by default
      str_io = StringIO.new svg
      image = MiniMagick::Image.create("svg", false) do |file|
        while chunk = str_io.read(8192)
          file.write chunk
        end
      end

      image.format format
      image.to_blob
    end

    self.response_body = render_to_string(:text => data, :template => nil)
  end
end
