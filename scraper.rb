#encoding: utf-8

# This is a template for a Ruby scraper on morph.io (https://morph.io)
# including some code snippets below that you should find helpful

require 'scraperwiki'
require 'nokogiri'

# Read in a page
url = "https://docs.google.com/spreadsheets/d/1QkkIRF-3Qrz-aRIxERbGbB7YHWz2-t4ix-7TEcuBNfE/pubhtml?gid=1823583981&single=true"
page = Nokogiri::HTML(open(url), nil, 'utf-8')
rows = page.xpath('//table[@class="waffle"]/tbody/tr')

# Find somehing on the page using css selectors
content = []
rows.collect do |r|
  content << r.xpath('td').map { |td| td.text.strip }
end

content.shift
content.each do |row|
  record = {
    "uid" => row[0],
    "category" => row[1],
    "promess" => row[2],
    "description" => row[3],
    "quality" => row[4],
    "fulfillment" => row[5],
    "ponderator" => row[6],
    "last_update" => Date.today.to_s
  }
  ScraperWiki.save_sqlite(["uid"], record)
  puts "Adds new record " + record['uid']
end

# p page.at('div.content')
#
# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})
#
# # An arbitrary query against the database
# ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries.
# You can use whatever gems you want: https://morph.io/documentation/ruby
# All that matters is that your final data is written to an SQLite database
# called "data.sqlite" in the current working directory which has at least a table
# called "data".
