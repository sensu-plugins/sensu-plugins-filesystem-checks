#! /usr/bin/env ruby
#
# check-fs-writable
#
# DESCRIPTION:
# This plugin checks that a filesystem is writable. Useful for checking for stale NFS mounts.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   ./check-fs-writable.rb --auto  (check all volgroups in fstab)
#   ./check-fs-writable.rb --dir /,/var,/usr,/home  (check a defined list of directories)
#
# NOTES:
#
# LICENSE:
#   Copyright 2014 Yieldbot, Inc  <Sensu-Plugins>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'tempfile'

#
# Check Filesystem Writable
#
class CheckFSWritable < Sensu::Plugin::Check::CLI
  option :dir,
         description: 'Directory to check for writability',
         short: '-d DIRECTORY',
         long: '--directory DIRECTORY',
         proc: proc { |a| a.split(',') }

  option :auto,
         description: 'Auto discover mount points via fstab',
         short: '-a',
         long: '--auto-discover'

  option :debug,
         description: 'Print debug statements',
         long: '--debug'

  # Setup variables
  #
  def initialize
    super
    @crit_pt_proc = []
    @crit_pt_test = []
  end

  # Generate output
  #
  def usage_summary
    if @crit_pt_test.empty? && @crit_pt_proc.empty?
      ok 'All filesystems are writable'
    elsif @crit_pt_test || @crit_pt_proc
      critical "The following file systems are not writeable: #{@crit_pt_test}, #{@crit_pt_proc}"
    end
  end

  # Get the volgroups
  #
  def acquire_vol_groups
    `vgdisplay|grep 'VG Name'|awk '{print $3}'`
  end

  # Get the mount points from the self namespace
  #
  def acquire_mnt_pts
    mnt_pts = []
    vol_groups = acquire_vol_groups.split("\n")
    vol_groups.each do |vol_group|
      `grep #{vol_group} /proc/self/mounts | awk '{print $2, $4}' | awk -F, '{print $1}' | awk '{print $1, $2}'`.split("\n").each do |mnt|
        mount_type_none = `mount | grep ' #{mnt.partition(' ').first} ' | sed -e "s/^.* type //g;s/ .*//g"`.strip
        puts "#{mnt.partition(' ').first} will be skipped because seems to be a bind/chroot mount" if mount_type_none == 'none' && config[:debug]
        mnt_pts << mnt unless mount_type_none == 'none'
      end
    end
    mnt_pts
  end

  # Does proc list the mount point as rw
  #
  def rw_in_proc?(mount_info)
    mount_info.each do |pt|
      @crit_pt_proc << pt.split[0].to_s if pt.split[1] != 'rw'
    end
  end

  # Create a tempfile at each mount point and attempt to write a line to it
  # If it can't write the line, or the mount point does not exist it will
  # generate a critical error
  #
  def rw_test?(mount_info)
    mount_info.each do |pt|
      (Dir.exist? pt.split[0]) || (@crit_pt_test << pt.split[0].to_s)
      file = Tempfile.new('.sensu', pt.split[0])
      puts "The temp file we are writing to is: #{file.path}" if config[:debug]
      # #YELLOW
      #  need to add a check here to validate permissions, if none it pukes
      file.write('mops') || @crit_pt_test << pt.split[0].to_s
      file.read || @crit_pt_test << pt.split[0].to_s
      file.close
      file.unlink
    end
  end

  # Auto-generate a list of mount points to check based upon the self
  # namespace in proc
  #
  def auto_discover
    mount_info = acquire_mnt_pts
    warning 'No mount points found' if mount_info.length == 0
    # #YELLOW
    #  I want to map this at some point to make it pretty and eaiser to read for large filesystems
    puts 'This is a list of mount_pts and their current status: ', mount_info if config[:debug]
    rw_in_proc?(mount_info)
    rw_test?(mount_info)
    puts "The critical mount points according to proc are: #{@crit_pt_proc}" if config[:debug]
    puts "The critical mount points according to actual testing are: #{@crit_pt_test}" if config[:debug]
    true
  end

  # Create a tempfile as each mount point and attempt to write a line to it
  # If it can't write the line, or the mount point does not exist it will
  # generate a critical error
  #
  def manual_test
    config[:dir].each do |d|
      (Dir.exist? d) || (@crit_pt_test << d.to_s)
      file = Tempfile.new('.sensu', d)
      puts "The temp file we are writing to is: #{file.path}" if config[:debug]
      # #YELLOW
      #  need to add a check here to validate permissions, if none it pukes
      file.write('mops') || @crit_pt_test << d.to_s
      file.read || @crit_pt_test << d.to_s
      file.close
      file.unlink
    end
  end

  # Main function
  #
  def run
    (auto_discover if config[:auto]) || (manual_test if config[:dir]) || (warning 'No directorties to check')
    usage_summary
  end
end
