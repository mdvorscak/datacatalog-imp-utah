require File.dirname(__FILE__) + '/output'
require File.dirname(__FILE__) + '/puller'

require 'uri'

class OrganizationPuller < Puller

  def initialize
    @source_page    = 'http://www.utah.gov/data/state_data_files.html'
    @source_index   = Output.file '/../cache/raw/source/index.html'
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
    doc = U.parse_html_from_file_or_uri(@source_page, @source_index, 
                                             :force_fetch => FORCE_FETCH)
	  table_rows = doc.xpath("//table//tr")
    format_cells = 2..5

	  table_rows.delete(table_rows[0])
	  table_rows.each do | row |
		  cells = row.css("td")

      format_cells.each do | x |
        org_metadata = get_org(cells[x])
        unless org_metadata.nil?
          already_exists = metadata.find { | data | data[:href] == org_metadata[:href] }
          metadata << org_metadata unless already_exists
          break
        end
      end

    end
  end

  def get_org(node)
	  a_tag = node.css("a").first
	  if a_tag
		  link = a_tag["href"]

		  #strip http:// out to make the next regex simpler
		  plain_link = link.gsub("http://", "")
		  #Only go to the first /
		  source_link = plain_link.scan(/.*?\//).first
		  	
      return { :href => "http://" + source_link.chop! ,
		           :name => source_link }
    else
      nil
    end
  end

end
