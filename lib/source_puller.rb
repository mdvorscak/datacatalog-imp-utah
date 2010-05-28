require File.dirname(__FILE__) + '/output'
require File.dirname(__FILE__) + '/puller'
#require File.dirname(__FILE__) + '/logger'

gem 'kronos', '>= 0.1.6'
require 'kronos'
require 'uri'

class SourcePuller < Puller

  def initialize
    @base_uri       = 'http://www.utah.gov/data/state_data_files.html'
    @details_folder = Output.dir  '/../cache/raw/source/detail'
    @index_data     = Output.file '/../cache/raw/source/index.yml'
    @index_html     = Output.file '/../cache/raw/source/index.html'
   # @pull_log       = Output.file '/../cache/raw/source/pull_log.yml'
    super
  end

  protected

  def get_metadata(doc)
	  table_rows=doc.xpath("//table//tr")

	  metadata=[]
	  table_rows.delete(table_rows[0])
	  table_rows.each do |row|
		  formats={:downloads=>{},:source=>{}}
		  cells=row.css("td")
		  add_format(formats,cells[2].inner_text,cells[2])
		  add_format(formats,cells[3].inner_text,cells[3])
		  add_format(formats,cells[4].inner_text,cells[4])
		  add_format(formats,cells[5].inner_text,cells[5])

		metadata<<{
			:title=>cells[0].inner_text,
			:description=>U.multi_line_clean(cells[1].inner_text),
			:formats=>formats
		}
	  end

	metadata
  end

  def add_format(formats,label,node)
	  a_tag=node.css("a").first
	  if a_tag
		  link=URI.unescape(a_tag["href"])
		  formats[:downloads][label]={:href=>link}
		  #strip http:// out to make the next regex simpler
		  link.gsub!("http://","")
		  #Only go to the first /
		  source_link=link.scan(/.*?\//).first
		  	
		  formats[:source][:source_url]="http://"+source_link
		  formats[:source][:source_org]=source_link.chop

	  end
  end

	def parse_metadata(metadata)
		m={
			:title=>metadata[:title],
			:description=>metadata[:description],
			:source_type=>"dataset",
			:catalog_name=>"utah.gov",
			:catalog_url=>@base_uri,
			:frequency=>"unknown"
		  }
		  downloads=[]
		  metadata[:formats][:downloads].each do |key,value|
			downloads<<{ :url=>value[:href],:format=>key}
		  end

		  source=metadata[:formats][:source]
		  m[:organization]={:home_url=>source[:source_url] ,
			  	    :name=>source[:source_org] }

		  m[:downloads]=downloads
		  m
	end

end
