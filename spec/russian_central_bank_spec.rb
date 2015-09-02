require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'RussianCentralBank' do
  before do
    rates_xml = File.open('spec/support/cbr.xml')
    stub_request(:get, "http://www.cbr.ru/scripts/XML_daily.asp?date_req=#{Time.now.strftime('%d/%m/%Y')}").
      with(headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Host'=>'www.cbr.ru',
        'User-Agent'=>'Ruby'
      }).
      to_return(status: 200, body: rates_xml, headers: {})
  end

  before :each do
    @bank = Money::Bank::RussianCentralBank.new
  end

  describe '#update_rates' do
    before do
      @bank.update_rates
    end

    it 'should update rates from daily rates service' do
      expect(@bank.rates['RUB_TO_USD']).to eq(0.016008273075525433)
      expect(@bank.rates['RUB_TO_EUR']).to eq(0.014582148533764966)
      expect(@bank.rates['RUB_TO_JPY']).to eq(1.9876685045974771)
    end
  end

  describe '#flush_rates' do
    before do
      @bank.add_rate('RUB', 'USD', 0.03)
    end

    it 'should delete all rates' do
      @bank.get_rate('RUB', 'USD')
      @bank.flush_rates
      expect(@bank.rates).to eq({})
    end
  end

  describe '#get_rate' do
    context 'getting dicrect rates' do
      before do
        @bank.flush_rates
        @bank.add_rate('RUB', 'USD', 0.03)
        @bank.add_rate('RUB', 'GBP', 0.02)
      end

      it 'should get rate from @rates' do
        expect(@bank.get_rate('RUB', 'USD')).to eq(0.03)
      end

      it 'should calculate indirect rates' do
        expect(@bank.get_rate('USD', 'GBP')).to eq(0.6666666666666667)
      end
    end

    context 'getting indirect rate' do
      let(:indirect_rate) { 4 }

      before do
        @bank.flush_rates
        @bank.add_rate('RUB', 'USD', 123)
        @bank.add_rate('USD', 'RUB', indirect_rate)
      end

      it 'gets indirect rate from the last set' do
        expect(@bank.get_rate('RUB', 'USD')).to eq(1.0 / indirect_rate)
      end
    end

    context "when ttl is not set" do
      before do
        @bank.add_rate('RUB', 'USD', 123)
        @bank.ttl = nil
      end

      it "should not update rates" do
        expect(@bank).not_to receive(:update_rates)
        @bank.get_rate('RUB', 'USD')
      end
    end

    context "when ttl is set" do
      before { @bank.add_rate('RUB', 'USD', 123) }

      context "and raks are expired" do
        before do
          @bank.instance_variable_set('@rates_updated_at', Time.now - 3600)
          @bank.ttl = 3600
        end

        it "should update rates" do
          expect(@bank).to receive(:update_rates)
          @bank.get_rate('RUB', 'USD')
        end
      end

      context "and ranks are not expired" do
        before do
          @bank.instance_variable_set('@rates_updated_at', Time.now - 3000)
          @bank.ttl = 3600
        end

        it "should not update rates" do
          expect(@bank).not_to receive(:update_rates)
          @bank.get_rate('RUB', 'USD')
        end
      end
    end
  end
end
