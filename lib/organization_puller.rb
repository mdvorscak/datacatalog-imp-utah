require File.dirname(__FILE__) + '/output'
require File.dirname(__FILE__) + '/puller'
#require File.dirname(__FILE__) + '/logger'

require 'uri'

class OrganizationPuller < Puller

  def initialize
    @base_uri       = 'http://www.utah.gov/government/agencylist.html'
    @details_folder = Output.dir  '/../cache/raw/organization/detail'
    @index_data     = Output.file '/../cache/raw/organization/index.yml'
    @index_html     = Output.file '/../cache/raw/organization/index.html'
   # @pull_log       = Output.file '/../cache/raw/source/pull_log.yml'
    super
  end

  protected

  def get_metadata(doc)
	metadata=[]
	#Need 2 seperate node sets because they have the same parent node
	links_block=doc.xpath('//div[@id="main"]//ul')
	headers=doc.xpath('//div[@id="main"]//h3')

	#Remove the first two ul tags
	2.times {links_block.delete(links_block.first)}
	links_block.size.times do |i|
		data={:org_type=>URI.unescape(headers[i].inner_text)}
		links_block[i].css("li").each do |link|
			#get the child node
			a_tag=link.css("a").first
			data[:name]=U.single_line_clean(a_tag.inner_text)
			data[:href]=URI.unescape(a_tag["href"])
			metadata<<{
				:org_type=>data[:org_type],
				:name=>data[:name],
				:href=>data[:href],
			}	
		end
	end
	metadata	
  end

# Returns as many fields as possible:
  #
  #   property :name
  #   property :names
  #   property :acronym
  #   property :org_type
  #   property :description
  #   property :slug
  #   property :url
  #   property :interest
  #   property :level
  #   property :source_count
  #   property :custom
  #
  def parse_metadata(metadata)
	{
      :name         => metadata[:name],
      :url          => metadata[:href],
      :catalog_name => "utah.gov",
      :catalog_url  => @base_uri,
      :org_type     => metadata[:org_type],
      :organization => { :name => "Utah" },

	}
  end
  
end
