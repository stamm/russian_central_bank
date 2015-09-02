# RussianCentralBank

This gem extends Money::Bank::VariableExchange with Money::Bank::RussianCentralBank and gives acceess to the Central Bank of Russia currency exchange.

## Installation

Add this line to your application's Gemfile:

    gem 'russian_central_bank'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install russian_central_bank

##Dependencies

* nokogiri
* money

## Usage

    bank = Money::Bank::RussianCentralBank.new

    # Load today's rates
    bank.update_rates

    # Or you can specify the date
    bank.update_rates(3.days.ago)

    Money.default_bank = bank

    # Exchange 100 USD to RUB
    100.to_money('USD').exchange_to('RUB')

    # Check last rates update
    bank.rates_updated_at

    # Check on which date rates were updated
    bank.rates_updated_on

    # Use ttl attribute to enable rates autoupdate
    bank.ttl = 1.day
    # Check expiration date
    bank.rates_expired_at

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
