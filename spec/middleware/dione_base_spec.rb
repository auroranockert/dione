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

require 'rack'
require 'dione'

describe Dione::DioneBase do
  let :configuration do
    {
      'database' => 'http://localhost:5984/dione',
      'middleware' => []
    }
  end

  let :ok do
    dione_base(-> (env) { [200, env, ['dione']] })
  end

  let :not_found do
    dione_base(-> (_) { fail Dione::NotFound })
  end

  def dione_base(app)
    Dione::DioneBase.new(app, configuration)
  end

  def env_for(url, opts = {})
    Rack::MockRequest.env_for(url, opts)
  end

  it 'Adds configuration and database' do
    _, env = ok.call(env_for('http://example.com/'))

    dione = env[:dione]

    expect(dione[:database].url).to eq('http://localhost:5984/dione')
    expect(dione[:configuration]).to eq(configuration)
  end

  it 'Returns properly for ok replies' do
    code, _, body = ok.call(env_for('http://example.com/'))

    expect(code).to eq(200)
    expect(body).to eq(['dione'])
  end

  it 'Returns properly when NotFound is raised' do
    code, _, body = not_found.call(env_for('http://example.com/'))

    expect(code).to eq(404)
    expect(body).to eq(['Sorry, could not be found'])
  end
end
