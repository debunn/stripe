# Query Returns

## Introduction
The Query Returns program is intended to parse a Payouts Return File (Specification v201904) from Caledonian Central Bank, and return detailed records for each requested recon token.  Please note that all reports queried by this program must be in this format.

## Prerequisites
- Version 2.6 (or higher) of the Ruby language (see here for installation documentation:  https://www.ruby-lang.org/en/documentation/installation/)

## Installation
- Download all included files, and place them in a directory of your choice
- From a terminal, navigate to the directory you placed the included files, and then run:
```bundle install```

## Usage
```ruby query_returns.rb recon_token[,recon_token2,...] [PayoutsReturn.csv]```

- When running the Query Returns program, at least one `recon_token` value must be specified.  Multiple `recon_token` values may be specified by separating them with commas (no spaces)
- By default, the Query Returns program will use the `PayoutsReturn.csv` file located in the same directory as the `query_returns.rb` file.  If you wish to specify a different report file, include the location of this report as the second parameter

