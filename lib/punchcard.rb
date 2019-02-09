# (c) 2017-2019 by Philipp Staender

require 'date'
require 'time'

class PunchCardError < StandardError
end

class PunchCard
  SETTINGS_DIR        = ENV['PUNCHCARD_DIR'] || File.expand_path('~/.punchcard')
  HOURLY_RATE_PATTERN = /^\s*(\d+)([^\d]+)*\s*/i.freeze
  TIME_POINT_PATTERN  = /^((\d+|.+?\s[\+\-]\d{4}?\s*)(\-)*(\d+|\s.+\d?)*)$/.freeze
  META_KEY_PATTERN    = /^([a-zA-Z0-9]+)\:\s*(.*)$/.freeze
  VERSION             = '1.1.0'.freeze

  attr_accessor :project

  def initialize(project_name)
    @wilcard_for_filename = ''
    @meta_data            = {}
    find_or_make_settings_dir
    return unless project_name

    self.project = project_name
    find_or_make_file
    read_project_data
  end

  def start
    output = []
    if start_time && !end_time
      output << "'#{project}' already started (#{humanized_total} total)"
      output << duration(start_time, timestamp).to_s
    else
      output << "'#{project}' started (#{humanized_total} total)"
      self.start_time = timestamp
    end
    output.join("\n")
  end

  def stop
    output = []
    if end_time
      output << "'#{@project}' already stopped (#{humanized_total} total)"
    elsif start_time
      output << "'#{@project}' stopped (#{humanized_total} total)"
      self.end_time = timestamp
    else
      output << 'Nothing to stop'
    end
    output.join("\n")
  end

  def toggle
    if active?
      stop
    else
      start
    end
  end

  def status
    project_exists_or_stop!
    find_or_make_file
    output = []
    output << (project + " (#{running_status})\n")
    output << humanized_total
    output.join("\n")
  end

  def details
    project_exists_or_stop!
    find_or_make_file
    output = []
    data = project_data
    data[0] = "#{data[0]} (#{running_status})"
    data.map do |line|
      points = line_to_time_points(line)
      unless points
        output << line + "\n"
        next
      end

      starttime = points[0]
      endtime   = points[1] || timestamp
      output << duration(starttime, endtime) + "\t" + self.class.format_time(Time.at(starttime)) + ' - ' + self.class.format_time(Time.at(endtime))
    end
    output << "========\n#{humanized_total}\t(total)"
    output.join("\n")
  end

  def csv
    project_exists_or_stop!
    find_or_make_file
    durations = []
    last_activity = nil
    project_data.map do |line|
      points = line_to_time_points(line)
      next unless points

      starttime = points[0]
      endtime   = points[1] || timestamp
      last_activity = points[1] || points[0]
      durations.push duration(starttime, endtime)
    end
    '"' + [
      @project,
      running_status,
      last_activity ? self.class.format_time(Time.at(last_activity).to_datetime) : '',
      humanized_total,
      hourly_rate ? hourly_rate[:hourlyRate].to_s + " #{hourly_rate[:currency]}" : '',
      hourly_rate ? (hourly_rate[:hourlyRate] * total / 3600.0).round(2).to_s + " #{hourly_rate[:currency]}" : ''
    ].join('","') + '"'
  end

  def remove
    if File.exist?(project_file)
      File.delete(project_file)
      "Deleted #{project_file}"
    end
  end

  def rename(new_project_name)
    old_filename = project_filename
    data         = project_data
    data[0]      = new_project_name
    write_string_to_project_file! data.join("\n")
    self.project = new_project_name
    File.rename(old_filename, project_filename) && "#{old_filename} -> #{project_filename}"
  end

  def project=(project_name)
    @project = project_name
    if @project.end_with?('*')
      @wilcard_for_filename = '*'
      @project              = @project.chomp('*')
    end
    @project.strip
  end

  def project
    @project.strip
  end

  def set(key, value)
    raise PunchCardError, "Key '#{key}' can only be alphanumeric" unless key =~ /^[a-zA-Z0-9]+$/

    @meta_data[key.to_sym] = value
    write_to_project_file!
    @meta_data
  end

  def total
    total = 0
    project_data.map do |line|
      points = line_to_time_points(line)
      next unless points

      starttime = points[0]
      endtime   = points[1] || timestamp
      total += endtime - starttime
    end
    total
  end

  def self.format_time(datetime)
    datetime.strftime('%F %T')
  end

  private

  def hourly_rate
    hourly_rate_found = @meta_data[:hourlyRate] && @meta_data[:hourlyRate].match(HOURLY_RATE_PATTERN)
    return unless hourly_rate_found

    {
      hourlyRate: hourly_rate_found[1].to_f,
      currency: hourly_rate_found[2] ? hourly_rate_found[2].strip : ''
    }
  end

  def project_exists_or_stop!
    raise PunchCardError, "'#{@project}' does not exists" unless project_exist?
  end

  def active?
    running_status == 'running'
  end

  def running_status
    start_time && !end_time ? 'running' : 'stopped'
  end

  def humanized_total
    humanize_duration total
  end

  def duration(starttime, endtime)
    if starttime
      humanize_duration endtime - starttime
    else
      humanize_duration 0
    end
  end

  def humanize_duration(duration)
    hours   = duration / (60 * 60)
    minutes = (duration / 60) % 60
    seconds = duration % 60
    "#{decimal_digits(hours)}:#{decimal_digits(minutes)}:#{decimal_digits(seconds)}"
  end

  def decimal_digits(digit)
    if digit.to_i < 10
      "0#{digit}"
    else
      digit.to_s
    end
  end

  def start_time
    time_points ? time_points[0] : nil
  end

  def start_time=(time)
    append_new_line timestamp_to_time(time)
  end

  def end_time=(time)
    replace_last_line "#{timestamp_to_time(start_time)} - #{timestamp_to_time(time)}"
  end

  def end_time
    time_points ? time_points[1] : nil
  end

  def time_points
    line_to_time_points last_entry
  end

  def line_to_time_points(line)
    matches = line.match(TIME_POINT_PATTERN)

    time_points = matches ? [string_to_timestamp(matches[2]), string_to_timestamp(matches[4])] : nil
    if time_points && time_points.reject(&:nil?).empty?
      nil
    else
      time_points
    end
  end

  def string_to_timestamp(str)
    return str if str.nil?

    str.strip!
    # This is some legacy... previous versions stored timestamp,
    # but now punched stores date-time strings for better readability.
    # So we have to convert timestamp and date-time format into timestamp here
    str =~ /^\d+$/ ? str.to_i : (str =~ /^\d{4}\-\d/ ? Time.parse(str).to_i : nil)
  end

  def last_entry
    project_data.last
  end

  def timestamp
    Time.now.to_i
  end

  def timestamp_to_time(timestamp)
    Time.at(timestamp)
  end

  def read_project_data
    title      = nil
    timestamps = []
    i          = 0
    File.open(project_file, 'r').each_line do |line|
      line.strip!
      if i.zero?
        title = line
      elsif line.match(META_KEY_PATTERN)
        set line.match(META_KEY_PATTERN)[1], line.match(META_KEY_PATTERN)[2]
      elsif line.match(TIME_POINT_PATTERN)
        timestamps.push line
      end
      i += 1
    end
    @project = title if title
    timestamps
  end

  def project_data
    File.open(project_file).each_line.map(&:strip)
  end

  def write_string_to_project_file!(string)
    File.open(project_file, 'w') { |f| f.write(string) }
  end

  def write_to_project_file!
    timestamps      = project_data.select { |line| line.match(TIME_POINT_PATTERN) }
    meta_data_lines = @meta_data.map { |key, value| "#{key}: #{value}" }
    write_string_to_project_file! [@project, meta_data_lines.join("\n"), timestamps].reject(&:empty?).join("\n")
  end

  def append_new_line(line)
    open(project_file, 'a') { |f| f.puts("\n" + line.to_s.strip) }
  end

  def replace_last_line(line)
    data     = project_data
    data[-1] = line
    write_string_to_project_file! data.join("\n")
  end

  def project_file
    Dir[project_filename + @wilcard_for_filename].sort_by { |f| File.mtime(f) }.reverse.first || project_filename
  end

  def project_filename
    SETTINGS_DIR + "/#{sanitize_filename(@project)}"
  end

  def project_exist?
    File.exist?(project_file)
  end

  def find_or_make_file
    write_string_to_project_file!(@project + "\n") unless project_exist?
    @project = project_data.first
  end

  def find_or_make_settings_dir
    Dir.mkdir(SETTINGS_DIR) unless File.exist?(SETTINGS_DIR)
  end

  def sanitize_filename(name)
    name.downcase.gsub(%r{(\\|/)}, '').gsub(/[^0-9a-z.\-]/, '_')
  end
end
