# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'punchcard'
require 'securerandom'

def example_settings_dir
  File.expand_path('./punchcard_test_data')
end

def setup_example_settings_dir
  Dir.glob(example_settings_dir + '/*').each { |file| File.delete(file) }
  PunchCard.send(:remove_const, :SETTINGS_DIR)
  PunchCard.const_set(:SETTINGS_DIR, example_settings_dir)
end

def punched_bin
  "PUNCHCARD_DIR=#{example_settings_dir} ../../bin/punched"
end

describe PunchCard do
  before do
    setup_example_settings_dir
  end

  let(:example_project) { PunchCard.new('My Project') }

  def random_project
    PunchCard.new("My random Project #{SecureRandom.hex}")
  end

  def my_project_file(filename = 'my_project')
    File.open("#{example_settings_dir}/#{filename}", 'r').read
  end

  def start_and_stop
    example_project.start
    sleep 0.1
    example_project.stop
    example_project
  end

  def two_seconds_tracking
    example_project.start
    sleep 2
    example_project
  end

  it 'should create a new PunchCard object' do
    expect(example_project).to be_a(PunchCard)
  end

  it 'should start a project' do
    example_project.start
  end

  it 'should start and stop a project' do
    start_and_stop
  end

  it 'should track a project time' do
    start_and_stop
    expect(my_project_file.lines.first.strip).to eq('My Project')
    expect(my_project_file.lines.last.strip).to match(/^\d+-\d+-\d+ .+? - \d+-\d+-\d+ /)
  end

  it 'should calculate tracked total time' do
    project      = two_seconds_tracking
    tracked_time = project.details.lines.last.match(/^\d{2}\:\d{2}\:(\d{2}).*total/)[1].to_i
    expect(tracked_time).to be_between 1, 3
    project      = two_seconds_tracking
    tracked_time = project.details.lines.last.match(/^\d{2}\:\d{2}\:(\d{2}).*total/)[1].to_i
    expect(tracked_time).to be_between 3, 5
  end

  it 'should toggle' do
    project = start_and_stop
    expect(project.status.lines.first).to match /stopped/
    project.toggle
    expect(project.status.lines.first).to match /running/
    project.toggle
    expect(project.status.lines.first).to match /stopped/
    expect(my_project_file.lines.last).to match(/^\d+/)
    expect(my_project_file.lines[-2]).to match(/^\d+/)
  end

  it 'should read and write utf8 names' do
    PunchCard.new 'Playing Motörhead'
    expect(my_project_file('playing_mot_rhead').strip).to eq('Playing Motörhead')
    project = PunchCard.new 'Playing*'
    expect(project.project).to eq('Playing Motörhead')
  end

  it 'should set hourlyRate' do
    project = start_and_stop
    project.set 'hourlyRate', '1000 €'
    expect(my_project_file.lines[1].strip).to eq('hourlyRate: 1000 €')
  end

  it 'should calculate earnings' do
    project = start_and_stop
    project.set 'hourlyRate', '1000EURO'
    project.toggle
    sleep 2
    project.toggle
    project.toggle
    sleep 2
    project.toggle
    expect(project.csv).to match /^"My Project","stopped","[0-9\-\s\:]+?","[0-9\:]+?","1000.0 EURO","1\.\d+ EURO"$/
  end

  it 'should track different projects simultanously' do
    project_a = random_project
    project_b = random_project
    expect(project_a.project).not_to eq(project_b.project)
    project_a.start
    project_b.start
    sleep 2
    project_a.stop
    sleep 2
    project_b.stop
    expect(project_b.total.to_i - project_a.total.to_i).to be_between(2, 4)
  end

  it 'should load latest project by wildcard' do
    project_a = random_project
    project   = PunchCard.new 'My random*'
    expect(project.project).to eq(project_a.project)
    sleep 1
    project_b = random_project
    project   = PunchCard.new 'My random*'
    expect(project.project).to eq(project_b.project)
    expect(project.project).not_to eq(project_a.project)
  end

  it 'should rename' do
    project = example_project
    content = my_project_file
    project.rename 'Renamed Project'
    expect(File.open("#{example_settings_dir}/renamed_project", 'r').read.strip).to eq(content.strip.sub(/My Project/, 'Renamed Project'))
    expect(File.exist?("#{example_settings_dir}/my_project")).to be_falsey
    expect(project.project).to eq('Renamed Project')
    project.start
    sleep 0.1
    project.stop
    content = File.open("#{example_settings_dir}/renamed_project", 'r').read.strip
    project.rename 'Other Project'
    expect(File.open("#{example_settings_dir}/other_project", 'r').read.strip).to eq(content.strip.sub(/Renamed Project/, 'Other Project'))
    expect(File.exist?("#{example_settings_dir}/renamed_project")).to be_falsey
  end

  it 'should remove' do
    project = example_project
    expect(File.exist?("#{example_settings_dir}/my_project")).to be_truthy
    project.remove
    expect(File.exist?("#{example_settings_dir}/my_project")).to be_falsey
  end

  it 'should call punched all' do
    two_seconds_tracking
    result = `#{punched_bin} all`
    expect(result).to match('My Project')
  end
end
