# frozen_string_literal: true

require 'spec_helper'
require 'rake'
require 'rubocop'

describe 'rubocop' do
  let(:cli) { instance_double(RuboCop::CLI) }

  before do
    Rake.application = Rake::Application.new
    load File.expand_path('../../lib/voxpupuli/test/rake/rubocop.rb', __dir__)
    allow(RuboCop::CLI).to receive(:new).and_return(cli)
  end

  it 'displays cop names without debug output' do
    expect(cli).to receive(:run) do |args|
      expect(args).to include('--display-cop-names')
      expect(args).not_to include('--debug')
      0
    end

    expect { Rake::Task['rubocop'].invoke }.to output.to_stdout
  end
end
