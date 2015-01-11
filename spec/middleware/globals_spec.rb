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

describe Dione::Globals do
  def globals(opts)
    Dione::Globals.new(-> (env) { [200, env, ['dione']] }, opts)
  end

  def env_for(url, database, previous_globals = nil)
    Rack::MockRequest.env_for(url, {}).tap do |env|
      env[:dione] = { database: database }
      env[:dione][:globals] = previous_globals if previous_globals
    end
  end

  it 'Gets globals from database' do
    db = instance_double('Dione::Database')

    expect(db).to receive(:reify).with('id' => 'a').and_return(:a).once
    expect(db).to receive(:reify).with('id' => 'b').and_return(:b).once

    middleware = globals('x' => 'a', 'y' => 'b')

    _, env = middleware.call(env_for('http://example.com/', db))

    expect(env[:dione][:globals]).to eq('x' => :a, 'y' => :b)
  end

  it 'Adds to globals hash if there already are globals' do
    db = instance_double('Dione::Database')

    expect(db).to receive(:reify).with('id' => 'a').and_return(:a).once

    middleware = globals('x' => 'a')

    _, env = middleware.call(env_for('http://example.com/', db, 'y' => :b))

    expect(env[:dione][:globals]).to eq('x' => :a, 'y' => :b)
  end
end
