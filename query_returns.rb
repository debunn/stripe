#! /usr/bin/env ruby

# query_returns.rb:
# This is the command line tool for querying Caledonia Central Bank's
# payout return file.  It can be called using the following syntax:
#
# ./query_returns.rb recon_token[,recon_token2,...] [PayoutsReturn.csv]
#
# The first parameter must be a single recon_token ("tk_xxxxx"), or a comma
# separated list of recon_token values to return ("tk_xxxxx,tk_yyyyy,...")
#
# The second parameter is optional, and will be the location of the payout
# return file to use (in CSV format).  If not specified, the default value
# will be "PayoutsReturn.csv"

require './query_class.rb'

# Verify a file is passed as a parameter - otherwise return usage
if ARGV.empty? || ARGV.length > 2 || ARGV[0] == '-h' || ARGV[0] == '--help'
    puts 'Incorrect parameters were provided.  Usage:'
    puts $0 + ' recon_token[,recon_token2,...] [PayoutsReturn.csv]'
    exit
end

# Create a new PayoutReturns object, which will load the requested file
if ARGV.length == 2 then
    # Use the supplied payout return file name
    payout_returns = PayoutReturns.new(ARGV[1])
else
    # Use the default payout return file name
    payout_returns = PayoutReturns.new
end

# Output the requested recon_token value(s)
payout_returns.output( ARGV[0].split(",") )