#! /usr/bin/env ruby
# encoding: UTF-8
#
#   check-file-exists
#
# DESCRIPTION:
# Sometimes you just need a simple way to test if your alerting is functioning
# as you've designed it. This test plugin accomplishes just that. But it can
# also be set to check for the existance of any file (provided you have
# read-level permissions for it)
#
# By default it looks in your /tmp folder and looks for the files CRITICAL,
# WARNING or UNKNOWN. If it sees that any of those exists it fires off the
# corresponding status to sensu. Otherwise it fires off an "ok".
#
# This allows you to fire off an alert by doing something as simple as:
# touch /tmp/CRITICAL
#
# And then set it ok again with:
# rm /tmp/CRITICAL
#
# Supports globbing for basic wildcard matching
# Wildcard charaters must be quoted or escaped to prevent shell expansion
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux, BSD
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   #YELLOW
#
# NOTES:
#
# LICENSE:
#   Copyright 2013 Mike Skovgaard <mikesk@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'

class CheckFileExists < Sensu::Plugin::Check::CLI
  option :critical,
         short: '-c CRITICAL',
         long: '--critical CRITICAL',
         default: '/tmp/CRITICAL'

  option :warning,
         short: '-w WARNING',
         long: '--warning WARNING',
         default: '/tmp/WARNING'

  option :unknown,
         short: '-u UNKNOWN',
         long: '--unknown UNKNOWN',
         default: '/tmp/UNKNOWN'

  option :present,
         short: '-p PRESENT',
         long: '--present PRESENT'

  def run
    critical_values = []
    warning_values = []
    unknown_values = []
    not_present_values = []

    Dir.glob(config[:critical]).each do |file|
      critical_values << file
    end

    Dir.glob(config[:warning]).each do |file|
      warning_values << file
    end

    Dir.glob(config[:unknown]).each do |file|
      unknown_values << file
    end

    unless config[:present].nil?
      unless File.exists?(config[:present])
        not_present_values << config[:present]
      end
    end

    if critical_values.any?
      critical "#{critical_values.count} matching file(s) found: #{critical_values.join(', ')}"
    elsif warning_values.any?
      warning "#{warning_values.count} matching file(s) found: #{warning_values.join(', ')}"
    elsif unknown_values.any?
      unknown "#{unknown_values.count} matching file(s) found: #{unknown_values.join(', ')}"
    elsif not_present_values.any?
      critical "#{not_present_values.count} matching file(s) not found: #{not_present_values.join(', ')}"
    elsif config[:present].instance_of?(String)
      ok "Matching file(s) found: #{config[:present]}"
    else
      ok 'No matching files found'
    end
  end
end
