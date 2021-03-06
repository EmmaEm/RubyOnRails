# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'
require 'shared_selenium_session'
require 'rspec/shared_spec_matchers'

CHROME_DRIVER = :selenium_chrome

browser_options = ::Selenium::WebDriver::Chrome::Options.new
browser_options.headless! if ENV['HEADLESS']
browser_options.add_option(:w3c, !!ENV['W3C'])

Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options, timeout: 30).tap do |driver|
    driver.browser.download_path = Capybara.save_path
  end
end

Capybara.register_driver :selenium_chrome_not_clear_storage do |app|
  chrome_options = {
    browser: :chrome,
    options: browser_options
  }
  Capybara::Selenium::Driver.new(app, chrome_options.merge(clear_local_storage: false, clear_session_storage: false))
end

module TestSessions
  Chrome = Capybara::Session.new(CHROME_DRIVER, TestApp)
end

skipped_tests = %i[response_headers status_code trigger]

$stdout.puts `#{Selenium::WebDriver::Chrome.driver_path} --version` if ENV['CI']

Capybara::SpecHelper.run_specs TestSessions::Chrome, CHROME_DRIVER.to_s, capybara_skip: skipped_tests do |example|
  case example.metadata[:full_description]
  when /#click_link can download a file$/
    skip 'Need to figure out testing of file downloading on windows platform' if Gem.win_platform?
  when /Capybara::Session selenium_chrome Capybara::Window#maximize/
    pending "Chrome headless doesn't support maximize" if ENV['HEADLESS']
  end
end

RSpec.describe 'Capybara::Session with chrome' do
  include Capybara::SpecHelper
  include_examples  'Capybara::Session', TestSessions::Chrome, CHROME_DRIVER
  include_examples  Capybara::RSpecMatchers, TestSessions::Chrome, CHROME_DRIVER

  context 'storage' do
    describe '#reset!' do
      it 'clears storage by default' do
        session = TestSessions::Chrome
        session.visit('/with_js')
        session.find(:css, '#set-storage').click
        session.reset!
        session.visit('/with_js')
        expect(session.evaluate_script('Object.keys(localStorage)')).to be_empty
        expect(session.evaluate_script('Object.keys(sessionStorage)')).to be_empty
      end

      it 'does not clear storage when false' do
        session = Capybara::Session.new(:selenium_chrome_not_clear_storage, TestApp)
        session.visit('/with_js')
        session.find(:css, '#set-storage').click
        session.reset!
        session.visit('/with_js')
        expect(session.evaluate_script('Object.keys(localStorage)')).not_to be_empty
        expect(session.evaluate_script('Object.keys(sessionStorage)')).not_to be_empty
      end
    end
  end

  context 'timeout' do
    it 'sets the http client read timeout' do
      expect(TestSessions::Chrome.driver.browser.send(:bridge).http.read_timeout).to eq 30
    end
  end

  describe 'filling in Chrome-specific date and time fields with keystrokes' do
    let(:datetime) { Time.new(1983, 6, 19, 6, 30) }
    let(:session) { TestSessions::Chrome }

    before do
      session.visit('/form')
    end

    it 'should fill in a date input with a String' do
      session.fill_in('form_date', with: '06/19/1983')
      session.click_button('awesome')
      expect(Date.parse(extract_results(session)['date'])).to eq datetime.to_date
    end

    it 'should fill in a time input with a String' do
      session.fill_in('form_time', with: '06:30A')
      session.click_button('awesome')
      results = extract_results(session)['time']
      expect(Time.parse(results).strftime('%r')).to eq datetime.strftime('%r')
    end

    it 'should fill in a datetime input with a String' do
      session.fill_in('form_datetime', with: "06/19/1983\t06:30A")
      session.click_button('awesome')
      expect(Time.parse(extract_results(session)['datetime'])).to eq datetime
    end
  end
end
