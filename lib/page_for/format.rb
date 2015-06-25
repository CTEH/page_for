module PageFor
  class Format
    def self.boolean(value)
      (value ? '<i class="fa fa-check-square-o"></i>' : '<i class="fa fa-square-o"></i>').html_safe
    end

    def self.float(value)
      "%.2f"%value rescue value
    end

    def self.string(value)
      value
    end

    def self.decimal(value)
      "%.2f"%value rescue value
    end

    def self.text(value)
      value
    end

    def self.datetime(value)
      PageFor.format_datetime(value)
    end

    def self.date(value)
      PageFor.format_date(value)
    end

    def self.integer(value)
      value
    end

    def self.enumerize(value)
      value.try(:text)
    end
  end
end