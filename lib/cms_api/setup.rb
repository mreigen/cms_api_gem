require 'active_support/core_ext/hash/deep_merge'    # for Hash#deep_merge
require 'active_support/core_ext/hash/keys'          # for Hash#deep_symbolize_keys
require 'active_support/core_ext/string/inflections' # for String#underscore
require 'uri'
require 'rest-client'
require 'yaml'
require 'ap'

DEFAULT_OPTIONS = {
  uris: {
    webr: {
      scheme: 'http',
      host:   'localhost',
      port:   3001
    },
    uploader: {
      scheme: 'http',
      host:   'localhost',
      port:   3004
    }
  },
  # this is the URL of a proxy auto-config file, a standard which RestClient apparently supports:
  proxy:                    "http://ps-auto.proxy.lexmark.com/proxypac",
  tenants:                  'lexmark',
  title:                    'imoonography',
  content_type:             'document',
  sample_file_origin:       './sample_files/origin/moon.jpg',
  sample_file_destination:  './sample_files/destination/moon.jpg',
  timeout:                  nil # i.e., do not timeout
}

def app_options
  config_file_options = YAML.load_file('./config/config.yml') || {}
  config_file_options.deep_symbolize_keys!
  modified_config_file_options = slugify_tenants(config_file_options)
  DEFAULT_OPTIONS.deep_merge(modified_config_file_options)
end

def timeout_options
  {
    timeout:      app_options[:timeout],
    open_timeout: app_options[:timeout]
  }
end

def slugify_tenants(config_file_options)
  if config_file_options[:tenants]
    config_file_options[:tenants] = config_file_options[:tenants].gsub('-', '_').parameterize('_')
  end
  config_file_options
end
