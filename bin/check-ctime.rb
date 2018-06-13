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
#  /opt/sensu/embedded/bin/check-ctime.rb -f /path/to/myFile.txt -w 600
#  /opt/sensu/embedded/bin/check-ctime.rb -d /path/to/myDirectory -w 600 -e
#
#  WINDOWS
#  * Use forward slashes for path!!
#  /opt/sensu/embedded/bin/ruby /opt/sensu/embedded/bin/check-ctime.rb -f c:/path/to/myFile.txt -w 600
#  /opt/sensu/embedded/bin/ruby /opt/sensu/embedded/bin/check-ctime.rb -d c:/path/to/myDirectory -w 600 -e
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

  option :warn,
         description: 'Warn if ctime greater than provided age in seconds',
         short: '-w SECONDS',
         long: '--warning SECONDS'

  option :crit,
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

  def run
    unknown 'No file or directory specified' unless config[:file] || config[:directory]
    unknown 'No warn or critical age specified' unless config[:warning_age] || config[:critical_age]

    requested_files = if config[:file]
                        Dir.glob(config[:file]
                      elsif config[:directory]
                        Dir.glob(config[:directory] + '/*')
                      end

    if !requested_files.empty?
      if config[:exclude_directories]
        requested_files = requested_files.reject { |f| File.directory?(f) } 
      end

      # Gets oldest file by creation time
      oldest_file = requested_files.min_by { |f| File.ctime f }
      age = Time.now.to_i - File.ctime(oldest_file).to_i

      critical "file is #{age - threshold} seconds past" if age >= config[:crit].to_i
      warning "file is #{age - threshold} seconds past" if age >= config[:warn].to_i
      ok "file is #{age} seconds old"
    elsif config[:ok_no_exist]
      ok 'file does not exist'
    else
      critical 'file not found'
    end
  end
end
