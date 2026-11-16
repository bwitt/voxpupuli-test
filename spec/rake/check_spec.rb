# frozen_string_literal: true

require 'spec_helper'
require 'rake'
require 'tmpdir'

describe 'check:utf8' do
  around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        Dir.mkdir('templates')
        example.run
      end
    end
  end

  before do
    Rake.application = Rake::Application.new
    load File.expand_path('../../lib/voxpupuli/test/rake/check.rb', __dir__)
  end

  let(:task) { Rake::Task['check:utf8'] }

  it 'accepts valid and empty files' do
    File.write('templates/valid.erb', "valid\n")
    File.write('templates/empty.erb', '')

    expect { task.invoke }.not_to raise_error
  end

  it 'rejects invalid files' do
    File.binwrite('templates/invalid.erb', "valid\ninvalid \xff\n")

    expect { task.invoke }.to raise_error(SystemExit).and output("templates/invalid.erb can't be parsed as UTF-8\n").to_stdout
  end
end
