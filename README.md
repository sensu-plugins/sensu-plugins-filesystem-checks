[![Sensu Bonsai Asset](https://img.shields.io/badge/Bonsai-Download%20Me-brightgreen.svg?colorB=89C967&logo=sensu)](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-filesystem-checks)
[ ![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-filesystem-checks.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-filesystem-checks)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-filesystem-checks.svg)](http://badge.fury.io/rb/sensu-plugins-filesystem-checks)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-filesystem-checks/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-filesystem-checks)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-filesystem-checks/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-filesystem-checks)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-filesystem-checks.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-filesystem-checks)

## Sensu Plugins Filesystem Checks Plugin

- [Overview](#overview)
- [Files](#files)
- [Usage examples](#usage-examples)
- [Configuration](#configuration)
  - [Sensu Go](#sensu-go)
    - [Asset registration](#asset-registration)
    - [Asset definition](#asset-definition)
    - [Check definition](#check-definition)
  - [Sensu Core](#sensu-core)
    - [Check definition](#check-definition)
- [Installation from source](#installation-from-source)
- [Additional notes](#additional-notes)
- [Contributing](#contributing)

### Overview

This plugin provides native instrumentation for monitoring and metrics collection, including health, usage, and various metrics of filesystem attributes.

### Files
 * bin/check-checksums.rb
 * bin/check-dir-count.rb
 * bin/check-dir-size.rb
 * bin/check-file-exists.rb
 * bin/check-file-size.rb
 * bin/check-fs-writable.rb
 * bin/check-mtime.rb
 * bin/check-tail.rb
 * bin/metrics-dirsize.rb
 * bin/metrics-filesize.rb
 * bin/metrics-nfsstat.rb
 
**check-checksums**
Checks a file against its checksum.

**check-dir-count**
Checks the number of files in a directory.

**check-dir-size**
Checks the size of a directory using `du`. Includes optional command line parameter to ignore a missing directory. WARNING: When using this with a directory with many files, there will be some lag as `du` recursively goes through the directory.

**check-file-exists**
Checks whether alerting is functioning as designed. Can be set to check for the existence of any file for which you have read-level permissions. Looks in `/tmp` folder for the files CRITICAL, WARNING, or UNKNOWN and if any are found, sends the corresponding status to Sensu (otherwise, sends an "ok"). This allows you to send an alert for something like `touch /tmp/CRITICAL` and then set it ok again with `rm /tmp/CRITICAL`. Supports globbing for basic wildcard matching. Wildcard charaters must be quoted or escaped to prevent shell expansion.

**check-file-size**
Checks the file size of a given file. Includes optional command line parameters to ignore missing files.

**check-fs-writable**
Checks that a filesystem is writable. Useful for checking for stale NFS mounts.

**check-mtime**
Checks a given file's modified time.

**check-tail**
Checks the tail of a file for a given patten and sends critical (or optional warning) message if found. Alternatively, failure can be triggered when the pattern is not found by passing the 'absent' flag.

**metrics-dirsize**
Provides a simple wrapper around `du` for getting directory size stats in real size, apparent size, and inodes (when supported).

**metrics-filesize**
Provies a simple wrapper around `stat` for getting file size stats in both in both, bytes and blocks.

**metrics-nfsstat**
Provides a simple wrapper around `nfsstat` for getting nfs server/client stats.

## Usage examples

### Help

**check-dir-count.rb**
```
Usage: check-dir-count.rb (options)
    -c, --critical NUM               Critical if count of files is greater than provided number (required)
    -d, --dir DIR                    Directory to count files in (required)
    -w, --warning NUM                Warn if count of files is greater than provided number (required)
```

**metrics-dirsize.rb**
```
Usage: metrics-dirsize.rb (options)
    -a, --apparent                   Report apparent size (bytes) (required)
    -d, --dir PATH                   Absolute path to directory to measure (required)
    -i, --inodes                     Report inodes used instead of bytes. Not all Linux distributions support this. (required)
    -r, --real                       Report real size (bytes) (required)
    -s, --scheme SCHEME              Metric naming scheme, text to prepend to metric (required)
```

## Configuration
### Sensu Go
#### Asset registration

Assets are the best way to make use of this plugin. If you're not using an asset, please consider doing so! If you're using sensuctl 5.13 or later, you can use the following command to add the asset: 

`sensuctl asset add sensu-plugins/sensu-plugins-logs`

If you're using an earlier version of sensuctl, you can download the asset definition from [this project's Bonsai asset index page](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-logs).

#### Asset definition

```yaml
---
type: Asset
api_version: core/v2
metadata:
  name: sensu-plugins-filesystem-checks
spec:
  url: https://assets.bonsai.sensu.io/ccce3fd9dd55770aeadd5034b674b763945454ac/sensu-plugins-filesystem-checks_2.0.0_centos_linux_amd64.tar.gz
  sha512: ecac91a77c2e27bb650dcb61a64d62fa92e98ffa1e754008b6b9bd94bf8e6c8862bdaf40ccf65447dd8be5e037acacb3fc2d20e39519167da05b55b0b9c3e880
```

#### Check definition

```yaml
---
type: CheckConfig
spec:
  command: "check-dir-count.rb"
  handlers: []
  high_flap_threshold: 0
  interval: 10
  low_flap_threshold: 0
  publish: true
  runtime_assets:
  - sensu-plugins/sensu-plugins-filesystem-checks
  - sensu/sensu-ruby-runtime
  subscriptions:
  - linux
```

### Sensu Core

#### Check definition
```json
{
  "checks": {
    "check-dir-count": {
      "command": "check-dir-count.rb",
      "subscribers": ["linux"],
      "interval": 10,
      "refresh": 10,
      "handlers": ["influxdb"]
    }
  }
}
```

## Installation from source

### Sensu Go

See the instructions above for [asset registration](#asset-registration).

### Sensu Core

Install and setup plugins on [Sensu Core](https://docs.sensu.io/sensu-core/latest/installation/installing-plugins/).

## Additional notes

### Sensu Go Ruby Runtime Assets

The Sensu assets packaged from this repository are built against the Sensu Ruby runtime environment. When using these assets as part of a Sensu Go resource (check, mutator, or handler), make sure to include the corresponding [Sensu Ruby Runtime Asset](https://bonsai.sensu.io/assets/sensu/sensu-ruby-runtime) in the list of assets needed by the resource.

## Contributing

See [CONTRIBUTING.md](https://github.com/sensu-plugins/sensu-plugins-filesystem-checks/blob/master/CONTRIBUTING.md) for information about contributing to this plugin.
