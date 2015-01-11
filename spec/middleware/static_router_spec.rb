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

describe Dione::StaticRouter do
  let :static_router do
    Dione::StaticRouter.new(-> (env) { [200, env, ['dione']] })
  end

  def env_for(database)
    Rack::MockRequest.env_for('http://example.com/route').tap do |env|
      env[:dione] = { database: database }
    end
  end

  def mock_view(db, return_value)
    expect(db).to receive(:query) do |doc, view, opts|
      expect(doc).to eq(:dione)
      expect(view).to eq(:routes)
      expect(opts).to eq(key: '/route')

      return_value
    end.once
  end

  it 'routes unique routes' do
    db = instance_double('Dione::Database')

    mock_view(db, [:a])

    _, env = static_router.call(env_for(db))

    expect(env[:dione][:page]).to eq(:a)
  end

  it 'routes to attachments' do
    db = instance_double('Dione::Database')
    obj = instance_double('Dione::Object')

    mock_view(db, [obj])

    expect(obj).to receive(:[]).with('_value').and_return('content.md')
    expect(obj).to receive(:attachment).with('content.md').and_return(:f)

    _, env = static_router.call(env_for(db))

    expect(env[:dione][:page]).to eq(:f)
  end

  it 'does not route non-existent routes' do
    db = instance_double('Dione::Database')

    mock_view(db, [])

    _, env = static_router.call(env_for(db))

    expect(env[:dione][:page]).to be_nil
  end

  it 'does not route non-unique routes' do
    db = instance_double('Dione::Database')

    mock_view(db, [:a, :b])

    _, env = static_router.call(env_for(db))

    expect(env[:dione][:page]).to be_nil
  end
end
