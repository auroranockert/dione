# Copyright 2014 Jens Nockert
#
# Licensed under the EUPL, Version 1.1 or – as soon they will be approved by
# the European Commission - subsequent versions of the EUPL (the "Licence"); You
# may not use this work except in compliance with the Licence. You may obtain a
# copy of the Licence at: https://joinup.ec.europa.eu/software/page/eupl
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the Licence is distributed on an "AS IS" basis, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# Licence for the specific language governing permissions and limitations under
# the Licence.

require 'json'

module Dione
  def self.configuration_path
    ENV['DIONE_CONFIG'] || 'config/local.dione'
  end

  def self.configuration
    @configuration ||= self.load_configuration(self.configuration_path)
  end

  def self.load_configuration(file)
    config = JSON.parse(File.read(file))

    if includes = config.delete('include')
      includes.each do |inc|
        config.merge!(self.load_configuration("#{File.dirname(file)}/#{inc}"))
      end
    end

    config
  end
end

require 'core/object'
require 'core/attachment'
require 'core/database'

require 'types/content'
require 'types/post'
require 'types/site'
require 'types/template'

Dir.glob("#{File.dirname(__FILE__)}/middleware/*.rb") do |middleware|
  require middleware
end
