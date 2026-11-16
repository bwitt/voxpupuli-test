# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'stringio'
require 'tmpdir'
require 'voxpupuli/test/rubocop_formatters/codeclimate'

describe CodeclimateFormatter do
  let(:offense) do
    buffer = Parser::Source::Buffer.new('foo.rb', source: "x = 1\n")
    location = Parser::Source::Range.new(buffer, 0, 1)
    RuboCop::Cop::Offense.new(:warning, location, 'Lint/UselessAssignment: Useless assignment to variable - `x`.',
                              'Lint/UselessAssignment')
  end

  def report_in_checkout
    Dir.mktmpdir do |dir|
      dir = File.realpath(dir)
      Dir.chdir(dir) do
        RuboCop::PathUtil.reset_pwd
        formatter = described_class.new(StringIO.new)
        formatter.file_finished(File.join(dir, 'lib', 'foo.rb'), [offense])
        formatter.output_array.first
      end
    end
  end

  it 'reports the offense' do
    expect(report_in_checkout).to include(
      check_name: 'UselessAssignment',
      description: 'Useless assignment to variable - `x`.',
      categories: ['Lint'],
      location: { path: 'lib/foo.rb', positions: { begin: { line: 1, column: 1 }, end: { line: 1, column: 1 } } },
      severity: 'major',
    )
  end

  it 'has a fingerprint independent of the checkout location' do
    fingerprints = Array.new(2) { report_in_checkout[:fingerprint] }

    expect(fingerprints.uniq.size).to eq(1)
  end
end
