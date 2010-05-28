gem 'datacatalog-importer', '>= 0.1.19'
require 'datacatalog-importer'

class Puller

  U = DataCatalog::ImporterFramework::Utility
  I = DataCatalog::ImporterFramework
  
  FETCH_DELAY = 0.3
  FORCE_FETCH = false 
  
  #Pull the initial data down and save it locally, parsed in easily readable form.
  def initialize
  #  @logger = Logger.new(@pull_log)
    document = U.parse_html_from_file_or_uri(@base_uri, @index_html, :force_fetch => FORCE_FETCH)

    @index_metadata=get_metadata(document)
    U.write_yaml(@index_data, @index_metadata) # for easy viewing later
  end

  #The fetch method is called repeatedly, each time it returns parsed metadata in the correct format for a single source.
  #When there is no metadata left nil is returned.
  def fetch
    sleep(FETCH_DELAY)
    data_from_index_page = @index_metadata.pop
    if data_from_index_page
    	return parse_metadata(data_from_index_page)
    end
    nil
  end


end
