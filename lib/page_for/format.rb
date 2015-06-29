module PageFor
  class Format
    def self.boolean(value, options)
      (value ? '<i class="fa fa-check-square-o"></i>' : '<i class="fa fa-square-o"></i>').html_safe
    end

    def self.float(value, options)
      "%.2f"%value rescue value
    end

    def self.string(value, options)
      value
    end

    def self.decimal(value, options)
      "%.2f"%value rescue value
    end

    def self.text(value, options)
      value
    end

    def self.datetime(value, options)
      PageFor.format_datetime(value)
    end

    def self.date(value, options)
      PageFor.format_date(value)
    end

    def self.integer(value, options)
      value
    end

    def self.enumerize(value, options)
      value.try(:text)
    end

    def self.binary(value, options)
      begin
        if value.class==Strongbox::Lock
          if options[:pass_phrase]
            begin
              return value.decrypt(options[:pass_phrase])
            rescue
              return "***********"
            end
          else
            return "***********"
          end
        else
          return "** BINARY DATA **"
        end
      rescue
        return "** BINARY DATA **"
      end
    end

  end # END FORMAT
end # END PAGEFOR
