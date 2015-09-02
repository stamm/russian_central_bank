require 'money'
require 'nokogiri'

class Money
  module Bank
    class RussianCentralBank < Money::Bank::VariableExchange

      attr_reader :rates_updated_at, :rates_updated_on, :ttl, :rates_expired_at

      def flush_rates
        @mutex.synchronize{
          @rates = {}
        }
      end

      def update_rates(date = Date.today)
        @mutex.synchronize{
          update_parsed_rates exchange_rates(date)
          @rates_updated_at = Time.now
          @rates_updated_on = date
          update_expired_at
          @rates
        }
      end

      def set_rate(from, to, rate)
        @rates[rate_key_for(from, to)] = rate
        @rates[rate_key_for(to, from)] = 1.0 / rate
      end

      def get_rate(from, to)
        update_rates if rates_expired?
        @rates[rate_key_for(from, to)] || indirect_rate(from, to)
      end

      def ttl=(value)
        @ttl = value
        update_expired_at
        @ttl
      end

      def rates_expired?
        rates_expired_at && rates_expired_at <= Time.now
      end

      private

      def update_expired_at
        @rates_expired_at = if ttl
          @rates_updated_at ? @rates_updated_at + ttl : Time.now
        else
          nil
        end
      end

      def indirect_rate(from, to)
        from_base_rate = @rates[rate_key_for('RUB', from)]
        to_base_rate = @rates[rate_key_for('RUB', to)]
        to_base_rate / from_base_rate
      end

      def exchange_rates(date)
        xml = Nokogiri::XML(Net::HTTP.get(URI(get_url(date))))
        xml.xpath('//ValCurs/Valute').map do |el|
          subs = el.elements
          hash = {}
          hash[:code] = subs.find {|v| v.name == 'CharCode' }.text
          hash[:nominal] = subs.find {|v| v.name == 'Nominal' }.text.to_i
          hash[:value] = subs.find {|v| v.name == 'Value' }.text.gsub(',', '.').to_f
          hash
        end
      end

      def get_url(date)
        "http://www.cbr.ru/scripts/XML_daily.asp?date_req=#{date.strftime('%d/%m/%Y')}"
      end

      def update_parsed_rates(rates)
        local_currencies = Money::Currency.table.map { |currency| currency.last[:iso_code] }
        add_rate('RUB', 'RUB', 1)
        rates.each do |hash|
          begin
            if local_currencies.include? hash[:code]
              add_rate('RUB', hash[:code], 1/ (hash[:value] / hash[:nominal]) )
            end
          rescue Money::Currency::UnknownCurrency
          end
        end
      end
    end
  end
end
