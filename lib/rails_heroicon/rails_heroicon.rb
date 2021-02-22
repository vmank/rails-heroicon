require "nokogiri"
require_relative "errors"

module RailsHeroicon
  class RailsHeroicon
    VARIANTS = %w[outline solid].freeze

    attr_reader :options

    def initialize(icon, variant: "outline", size: nil, **options)
      raise UndefinedVariant unless VARIANTS.include?(variant.to_s)

      @icon = icon.to_s
      @variant = variant.to_s
      @options = options
      @size = icon_size_with(size)

      @options.merge!(a11y)
      @options.merge!({
        viewBox: outline? ? "0 0 24 24" : "0 0 20 20",
        height: @size,
        width: @size,
        version: "1.1",
        fill: outline? ? "none" : "currentColor",
        stroke: solid? ? "none" : "currentColor"
      })
    end

    def svg_path
      file_path = if solid?
                    "#{SOLID_ICON_PATH}/#{@icon}.svg"
                  else
                    "#{OUTLINE_ICON_PATH}/#{@icon}.svg"
                  end

      raise UndefinedIcon, @icon unless File.exist?(file_path)

      file = File.read(file_path)
      doc = Nokogiri::HTML(file)
      doc.css("path").remove_attr("stroke")
      doc.css("path").remove_attr("fill")
      doc.at_css("svg").inner_html
    end

    private

    def a11y
      accessible = {}

      if @options[:"aria-label"].nil? && @options["aria-label"].nil?
        accessible[:"aria-hidden"] = "true"
      else
        accessible[:role] = "img"
      end

      accessible
    end

    def icon_size_with(size)
      if size
        size
      elsif outline? && size.nil?
        24
      elsif solid? && size.nil?
        20
      end
    end

    def outline?
      @variant == "outline"
    end

    def solid?
      @variant == "solid"
    end
  end
end
