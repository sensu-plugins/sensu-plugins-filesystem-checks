## Sensu-Plugins-filesystem-checks

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-filesystem-checks.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-filesystem-checks)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-filesystem-checks.svg)](http://badge.fury.io/rb/sensu-plugins-filesystem-checks)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-filesystem-checks/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-filesystem-checks)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-filesystem-checks/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-filesystem-checks)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-filesystem-checks.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-filesystem-checks)
[ ![Codeship Status for sensu-plugins/sensu-plugins-filesystem-checks](https://codeship.com/projects/4b97d0a0-db4c-0132-445b-5ad94843e341/status?branch=master)](https://codeship.com/projects/79592)

## Functionality

## Files
 * bin/check-dir-count
 * bin/check-checksums
 * bin/check-file-exists
 * bin/check-fs-writable
 * bin/check-mtime
 * bin/check-tail
 * bin/metric-dirsize
 * bin/metric-filesize

## Usage

## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install sensu-plugins-filesystem-checks -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

#### Rubygems

`gem install sensu-plugins-filesystem-checks`

#### Bundler

Add *sensu-plugins-disk-checks* to your Gemfile and run `bundle install` or `bundle update`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-filesystem-checks' do
  options('--prerelease')
  version '0.0.1'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-filesystem-checks' do
  options('--prerelease')
  version '0.0.1'
end
```

## Notes
