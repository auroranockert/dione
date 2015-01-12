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

describe Dione::Attachment do
  let :defaults do
    {
      'photo.jpg' => {
        'content_type' => 'image/jpeg',
        'digest' => 'md5-7Pv4HW2822WY1r/3WDbPug==',
        'length' => 165504,
        'revpos' => 2,
        'stub' => true
      }
    }
  end

  def attachment(root, name, attachments = nil)
    expect(root).to receive(:[]).with('_attachments') { defaults }
    expect(root).to receive(:[]).with('attachments') { attachments }

    Dione::Attachment.new(root, name)
  end

  it 'raise error for non-existing attachments' do
    obj = instance_double('Dione::Object')

    expect(obj).to receive(:[]).with('_attachments').and_return({})

    expect { Dione::Attachment.new(obj, 'f') }.to raise_error(ArgumentError)
  end

  it 'calculates content properties' do
    att = attachment(instance_double('Dione::Object'), 'photo.jpg')

    expect(att.content_type).to eq('image/jpeg')
    expect(att.content_length).to eq(165504)
  end

  it 'merges couchdb and dione metadata properly' do
    md = {
      'photo.jpg' => { 'content_type' => 'image/png', 'length' => 12, 'a' => 1 }
    }

    att = attachment(instance_double('Dione::Object'), 'photo.jpg', md)

    expect(att.content_type).to eq('image/jpeg')
    expect(att.content_length).to eq(165504)
    expect(att['a']).to eq(1)
  end

  it 'delivers content properly' do
    obj = instance_double('Dione::Object')
    db = instance_double('Dione::Database')

    expect(obj).to receive(:database).and_return(db)
    expect(db).to receive(:fetch_attachment).with(obj, 'photo.jpg') { :data }

    att = attachment(obj, 'photo.jpg')

    expect(att.content).to eq(:data)
  end

  it 'responds to a get request' do
    obj = instance_double('Dione::Object')
    db = instance_double('Dione::Database')

    expect(obj).to receive(:database).and_return(db)
    expect(db).to receive(:fetch_attachment).with(obj, 'photo.jpg') { :data }

    att = attachment(obj, 'photo.jpg')

    response = Rack::MockRequest.new(att).get('/')

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to eq('image/jpeg')
    expect(response.body).to eq('data')
  end

  it 'responds to a head request' do
    att = attachment(instance_double('Dione::Object'), 'photo.jpg')

    response = Rack::MockRequest.new(att).head('/')

    expect(response.status).to eq(200)
    expect(response.headers).to eq(
      'Content-Type' => 'image/jpeg',
      'Content-Length' => '165504'
    )
    expect(response.body).to eq('')
  end

  it 'responds to a post request' do
    att = attachment(instance_double('Dione::Object'), 'photo.jpg')

    response = Rack::MockRequest.new(att).post('/')

    expect(response.status).to eq(405)
    expect(response.headers['ALLOW']).to eq('GET, HEAD')
    expect(response.body).to eq('')
  end
end
