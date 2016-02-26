#!/usr/bin/env ruby
#
#   metrics-nfsstat
#
# DESCRIPTION:
#   Simple wrapper around `nfsstat` for getting nfs server/client stats.
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Copyright 2016 Mitsutoshi Aoe
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'socket'
require 'sensu-plugin/metric/cli'

class NfsstatMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.nfsstat"

  def run
    output = `/usr/sbin/nfsstat -l`

    output.each_line do |line|
      next unless /^nfs\s+(.+):\s+(\d+)/ =~ line
      key = Regexp.last_match[1].split.join('.')
      val = Regexp.last_match[2].to_i
      output "#{config[:scheme]}.#{key}", val
    end

    ok
  end
end
