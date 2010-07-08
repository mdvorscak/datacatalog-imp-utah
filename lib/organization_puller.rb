require File.dirname(__FILE__) + '/output'
require File.dirname(__FILE__) + '/puller'

require 'uri'

class OrganizationPuller < Puller

  def initialize
    @base_uri       = 'http://www.utah.gov/government/agencylist.html'
    @details_folder = Output.dir  '/../cache/raw/organization/detail'
    @index_data     = Output.file '/../cache/raw/organization/index.yml'
    @index_html     = Output.file '/../cache/raw/organization/index.html'
    super
  end

  protected

  def get_metadata(doc)
	metadata = []
	#Need 2 seperate node sets because they have the same parent node
	links_block = doc.xpath('//div[@id="main"]//ul')
	headers = doc.xpath('//div[@id="main"]//h3')

	#Remove the first two ul tags
	2.times { links_block.delete(links_block.first) }
	links_block.size.times do | i |
		links_block[i].css("li").each do | link |
			#get the child node
			a_tag = link.css("a").first
			name = U.single_line_clean(a_tag.inner_text)
      link = URI.unescape(a_tag["href"])

      #Check for local links and susbtitue appropriately
      if link.match(/\.\.\/.*/)
         link.gsub!(/^\.\./ , "http://www.utah.gov")
      end

      #remove the final /, if there is one
      link.gsub!(/\/$/ , "")

			metadata << {
				:name => name,
				:href => link,
			}	
		end
	end
  #Adds organizations that are not include in the organization page but are used as sources
  #for the source page.
  append_bonus_data(metadata)
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
      :org_type     => "governmental",
      :organization => { :name => "Utah" },

	}
  end

  private

  def append_bonus_data(metadata)
    metadata << { :name => "jobs.utah.gov" ,      :href => "http://jobs.utah.gov" }
    metadata << { :name => "governor.utah.gov" ,  :href => "http://governor.utah.gov" }
    metadata << { :name => "mesowest.utah.edu" ,  :href => "http://mesowest.utah.edu" }
    metadata << { :name => "www.e911.utah.gov" ,  :href => "http://www.e911.utah.gov" }
    metadata << { :name => "www.co.weber.ut.us" , :href => "http://www.co.weber.ut.us" }
  end
end
