# Copyright 2014 Jens Nockert
#
# Licensed under the EUPL, Version 1.1 or – as soon they will be approved by
# the European Commission - subsequent versions of the EUPL (the 'Licence'); You
# may not use this work except in compliance with the Licence. You may obtain a
# copy of the Licence at: https://joinup.ec.europa.eu/software/page/eupl
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the Licence is distributed on an 'AS IS' basis, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# Licence for the specific language governing permissions and limitations under
# the Licence.

require 'spec_helper'

describe Dione do
  let :default do
    {
      'database' => 'http://localhost:5984/dione',
      'middleware' => ['Dione::StaticRouter', 'Dione::Globals'],
      'options' => {
        'Dione::Globals' => { 'site' => 'site' }
      }
    }
  end

  it 'follows the default path' do
    expect(Dione.configuration_path).to eq('config/local.dione')
  end

  it 'follows the configuration path in DIONE_CONFIG' do
    ENV['DIONE_CONFIG'] = 'dione.config'

    expect(Dione.configuration_path).to eq('dione.config')
  end

  it 'loads the configuration set in DIONE_CONFIG' do
    ENV['DIONE_CONFIG'] = 'config/local.example.dione'

    expect(Dione.configuration).to eq(default)
  end
end
