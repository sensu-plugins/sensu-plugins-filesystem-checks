#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

### Added
- Added 'check-ctime.rb' for checking the file created time (@landondao1)

## [Unreleased]

### Added
- Updated asset build targets to support centos6

## [2.0.0] - 2019-05-07
### Breaking Changes
- Update minimum required ruby version to 2.3. Drop unsupported ruby versions.
- Bump `sensu-plugin` dependency from `~> 1.2` to `~> 4.0` you can read the changelog entries for [4.0](https://github.com/sensu-plugins/sensu-plugin/blob/master/CHANGELOG.md#400---2018-02-17), [3.0](https://github.com/sensu-plugins/sensu-plugin/blob/master/CHANGELOG.md#300---2018-12-04), and [2.0](https://github.com/sensu-plugins/sensu-plugin/blob/master/CHANGELOG.md#v200---2017-03-29)

### Added
- Added testing on Ruby 2.4.1 (@portertech)
- Travis build automation to generate Sensu Asset tarballs that can be used n conjunction with Sensu provided ruby runtime assets and the Bonsai Asset Index
- Require latest sensu-plugin for [Sensu Go support](https://github.com/sensu-plugins/sensu-plugin#sensu-go-enablement)

## [1.0.0] - 2017-07-01
### Added
- Added testing on Ruby 2.3.0 (@Evesy)
- Added support for globbing in 'check-file-exists.rb' (@Evesy)
- Added 'metrics-nfsstat.rb' for collecting nfsstat metrics (@maoe)

### Breaking Changes
- Dropped Ruby 1.9 support

### Changed
- Renamed metric-{dirsize,filename} to metrics-{dirsize,filename}

## [0.1.0] - 2015-08-04
### Added
- Added new checks for file and directory size

## [0.0.4] - 2015-08-04 (Pulled)
### Changed
- Added 'check-dir-size.rb' for checking the total size of a directory
- Recommited 'check-file-size.rb' from previous repo, with a couple of updates
- general gem cleanup

## [0.0.3] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

### Added
- can now use multi volgroups with autodiscovery
- the ability to feed a file containing a hash into check-checksums.rb

## [0.0.2] - [2015-06-02]
### Fixed
- added binstubs

### Changed
- removed cruft from /lib

## 0.0.1 - [2015-04-30]
### Added
- initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-filesystem-checks/compare/2.0.0...HEAD
[2.0.0]: https://github.com/sensu-plugins/sensu-plugins-filesystem-checks/compare/1.0.0...2.0.0
[1.0.0]: https://github.com/sensu-plugins/sensu-plugins-filesystem-checks/compare/0.0.4...1.0.0
[0.1.0]: https://github.com/sensu-plugins/sensu-plugins-filesystem-checks/compare/0.0.3...0.0.4
[0.0.4]: https://github.com/sensu-plugins/sensu-plugins-filesystem-checks/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-filesystem-checks/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-filesystem-checks/compare/0.0.1...0.0.2
