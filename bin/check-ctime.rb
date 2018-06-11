#! /usr/bin/env ruby
#
#   check-ctime
#
# DESCRIPTION:
#   This plugin checks a given file's created time.
#   If a directory is passed in, it will get the oldest
#   file in the directory.
#
#   This is useful when checking to see if a file or
#   directory is being cleared out.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux, Windows
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#  LINUX
#  check-ctime.rb -f /path/to/myFile.txt -w 600
#  check-ctime.rb -d /path/to/myDirectory -w 600 -e
#
#  WINDOWS
#  * Use forward slashes for path!!
#  check-ctime.rb -f c:/path/to/myFile.txt -w 600
#  check-ctime.rb -d c:/path/to/myDirectory -w 600 -e
#
# NOTES:
#
# LICENSE:
#   Copyright 2014 Sonian, Inc. and contributors.
#   <support@sensuapp.org> and <landon.dao@ge.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'fileutils'

class Ctime < Sensu::Plugin::Check::CLI
  option :file,
         description: 'File (or directory) to check created time',
         short: '-f FILE',
         long: '--file FILE'

  option :directory,
         description: 'Directory to check oldest file created time',
         short: '-d DIRECTORY',
         long: '--directory DIRECTORY'

  option :warning_age,
         description: 'Warn if ctime greater than provided age in seconds',
         short: '-w SECONDS',
         long: '--warning SECONDS'

  option :critical_age,
         description: 'Critical if ctime greater than provided age in seconds',
         short: '-c SECONDS',
         long: '--critical SECONDS'

  option :exclude_directories,
         description: 'Ignores directories (used when passing in a directory)',
         short: '-e',
         long: '--exclude-directories',
         boolean: true,
         default: false

  option :ok_no_exist,
         description: 'OK if file does not exist',
         short: '-o',
         long: '--ok-no-exist',
         boolean: true,
         default: false

  def selected_file
    files = Dir.glob(config[:file]) if config[:file]
    files = Dir.glob(config[:directory] + '/*') if config[:directory]
    files = files.select { |f| File.file?(f) } if config[:exclude_directories]
    # Gets oldest file by creation time
    files.min_by { |f| File.ctime f }
  end

  def run_check(type, age)
    threshold =  config["#{type}_age".to_sym].to_i
    send(type, "file is #{age - threshold} seconds past #{type}") if threshold > 0 && age >= threshold
  end

  def run
    unknown 'No file or directory specified' unless config[:file] || config[:directory]
    unknown 'No warn or critical age specified' unless config[:warning_age] || config[:critical_age]

    if selected_file
      age = Time.now.to_i - File.ctime(selected_file).to_i
      run_check(:critical, age) || run_check(:warning, age) || ok("file is #{age} seconds old")
    else
      if config[:ok_no_exist]
        ok 'file does not exist'
      else
        critical 'file not found'
      end
    end
  end
end
