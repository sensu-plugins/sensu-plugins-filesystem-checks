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
#  check-windows-ctime.rb -f myFile.txt -w 600
#  check-windows-ctime.rb -d myDirectory -w 600 -eo
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

  def get_file()
    if config[:file]
        return Dir.glob(config[:file]).first
    else
        # Gets oldest file in directory
        files = Dir.glob(config[:directory] + "/*")
        if config[:exclude_directories]
            files = files.select { |f| File.file?(f) }
        end
        return files.sort_by { |f| File.ctime f }.first
    end 
  end 

  def run_check(type, age)
    to_check = config["#{type}_age".to_sym].to_i
    if to_check > 0 && age >= to_check 
      send(type, "file is #{age - to_check} seconds past #{type}")
    end
  end

  def run
    unknown 'No file or directory specified' unless config[:file] || config[:directory]
    unknown 'No warn or critical age specified' unless config[:warning_age] || config[:critical_age]

    file = get_file()
    if file
      age = Time.now.to_i - File.ctime(file).to_i
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