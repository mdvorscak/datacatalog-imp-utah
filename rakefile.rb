require File.dirname(__FILE__) + '/lib/organization_puller'
require File.dirname(__FILE__) + '/lib/source_puller'

gem 'datacatalog-importer', '~> 0.1.19'
require 'datacatalog-importer'

def setup
  config_file = File.dirname(__FILE__) + '/config.yml'
  config = YAML.load_file(config_file)
  env = ENV['IMPORTER_ENV']
  raise "IMPORTER_ENV undefined" unless env
  raise "IMPORTER_ENV invalid" unless config[env]
  DataCatalog::ImporterFramework::Tasks.new({
    :api_key      => config[env]['api_key'],
    :base_uri     => config[env]['base_uri'],
    :cache_folder => File.dirname(__FILE__) + '/cache/parsed',
    :name         => "Utah State Data Catalog",
    :uri          => "http://www.utah.gov/data/state_data_files.html",
    :pullers	  =>  {
    	:source	  	=> SourcePuller,
	:organization 	=> OrganizationPuller,
    },
  })
end

setup
