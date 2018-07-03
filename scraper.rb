#encoding: utf-8

# This is a template for a Ruby scraper on morph.io (https://morph.io)
# including some code snippets below that you should find helpful

require 'scraperwiki'
require 'nokogiri'

def valid_date row
  if !row.empty?
    d,m,a = row.split '/'
    if Date.valid_date? a.to_i, m.to_i, d.to_i
      return true
    end
  end
  return false
end

def get_news(gid)
  # Read in a page
  url = "https://docs.google.com/spreadsheets/d/1AWDMIZsE9k3jQaJlgCKBt8vwVHg4Tg4MqHd-09CRc6I/pubhtml?gid="+gid+"&single=true"
  page = Nokogiri::HTML(open(url), nil, 'utf-8')
  rows = page.xpath('//table[@class="waffle"]/tbody/tr')

  # Find somehing on the page using css selectors
  content = []
  rows.collect do |r|
    content << r.xpath('td').map { |td| td.text.strip }
  end

  content.shift
  # p content
  content.each do |row|
    if row[2] != "" && valid_date(row[0])
      date_news_y = DateTime.parse(row[0]).strftime("%Y").to_i
      date_news_m = DateTime.parse(row[0]).strftime("%-m").to_i
      date_news_d = DateTime.parse(row[0]).strftime("%-d").to_i

      puts "titular: "+ row[2]
      puts "y: "+date_news_y.to_s+" m: "+date_news_m.to_s+" d: "+date_news_d.to_s

      record = {
        "id" => Digest::SHA1.hexdigest(row[6].gsub(/\s+/, "")),
        "fecha" => DateTime.parse(Date.new(date_news_y,date_news_m,date_news_d).to_time.to_s).strftime('%Q'),
        "medio" => row[1],
        "titular" => row[2],
        "imagen" => row[3],
        "bajada" => row[4],
        "tipo_prensa" => row[5],
        "link" => row[6],
        "temas" => row[7],
        "observaciones" => row[8],
        "prensa_internacional" => row[9],
        "destacada" => row[10],
        "created_at" => Date.today.to_s
      }

      # Storage records
      if ((ScraperWiki.select("* from data where `id`='#{record['id']}'").empty?) rescue true)
        ScraperWiki.save_sqlite(["id"], record)
        p record['fecha']
        puts "Adds new record from " + record['id']
      else
        ScraperWiki.save_sqlite(["id"], record)
        puts "Updating already saved record from " + record['id']
      end
    end
  end
end

a_gid = ['494757158','1616582078','1546052280','1989196281','374723069','1280486090','1992522200','1647747674','1237256646',
  '207042622','1904134755','750032542','964559127','1680581524','1788956503','1804038255','323928586','1688493548','2099281574',
  '1527990113','659077012','1486071435','1785944442','346220951','610309247','1674907040','1497604527','1577843634', '1555485015', '306062498', '1707241634']
a_gid.each do | gid |
  get_news(gid);
end
