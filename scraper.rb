# frozen_string_literal: true

$LOAD_PATH << "./lib"

require "epathway_scraper"

def scrape(authorities)
  exceptions = {}
  authorities.each do |authority_label|
    puts "\nScraping authority #{authority_label}..."
    begin
      EpathwayScraper.scrape_authority(authority_label) do |record|
        record["authority_label"] = authority_label.to_s

        EpathwayScraper.log(record)
        ScraperWiki.save_sqlite(%w[authority_label council_reference], record)
      end
    rescue StandardError => e
      warn "#{authority_label}: ERROR: #{e}"
      warn e.backtrace
      exceptions[authority_label] = e
    end
  end
  exceptions
end

authorities = EpathwayScraper::AUTHORITIES.keys
puts "Scraping authorities: #{authorities.join(', ')}"
exceptions = scrape(authorities)

unless exceptions.empty?
  puts "\n***************************************************"
  puts "Now retrying authorities which earlier had failures"
  puts "***************************************************"

  exceptions = scrape(exceptions.keys)
end

unless exceptions.empty?
  raise "There were errors with the following authorities: #{exceptions.keys}. " \
        "See earlier output for details"
end
