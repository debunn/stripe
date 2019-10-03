# This is the class definition file for the PayoutReturn and PayoutReturns class

# Load the Ruby CSV library so we can parse the returns file
require 'csv'

# Load the Ruby Money library to handle currency value formatting
require 'money'

# Use the currency localization (output format to match currency type)
Money.locale_backend = :currency

# This class is intended to represent an individual return item
class PayoutReturn

    def initialize(post_date, recon_token, currency, amount,
        return_reason_code)
        
        @post_date = DateTime.strptime(post_date, '%Y%m%d')
        @recon_token = recon_token  # <= 30 char string
        @currency = currency  # 3-letter ISO currency code
        @amount = amount  # payout return amount
        @money = Money.new(@amount, @currency)
        @return_reason_code = return_reason_code  # 3 digit reason code
        @return_reason_text = { "001" => "Invalid account number", 
            "002" => "Invalid routing number",
            "003" => "Invalid amount",
            "004" => "Unsupported currency",
            "005" => "Account debits unsupported",
            "006" => "Unknown failure" }
    end

    def output
        # Output the nicely formatted return information for this record

        puts 'Payout Return Token: ' + @recon_token
        puts 'Payout Post Date: ' + @post_date.strftime("%Y-%m-%d")
        puts @money.format(symbol: false) + ' ' + @currency
        if @return_reason_text.has_key?(@return_reason_code)
            puts 'Error Details: "' + @return_reason_code + ' -- ' + 
            @return_reason_text[@return_reason_code] + '"'
        else
            puts 'Error Details: "' + @return_reason_code + '"'
        end
        puts ''
    end

end

# This class is intended to parse the payouts return file, and
# generate a hash of PayoutReturn objects, using the recon_token
# as the hash key value
class PayoutReturns

    def initialize(return_file = "PayoutsReturn.csv")
        @payout_returns = {}

        # Query the Money::Currency.table object, and retrieve an array of all valid currency codes
        @currency_array = all_currencies(Money::Currency.table)

        begin
            # Read CSV values from the requested return file
            csv_table = CSV.read(return_file, headers: true)

            csv_table.each_with_index do |row,i|
                # For each line in the CSV, validate the values, then create a corresponding
                # PayoutReturn object in the @payout_returns hash

                # Set the valid_ecord flag to true
                valid_record = true

                # Verify that the date is 8 numeric digits only
                if row["post_date"] != "#{row["post_date"].to_i}" || 
                    row["post_date"].length != 8 || 
                    !Date.valid_date?(row["post_date"][0..3].to_i,row["post_date"][4..5].to_i,row["post_date"][6..7].to_i)
                    puts 'Warning: row ' + i.to_s + 
                       ' of the payouts return file contains an invalid date: ' + 
                        row["post_date"] + ' and has been ignored.'
                    valid_record = false
                end

                # Verify that the recon token is 30 characters or less
                if row["recon_token"].length > 30
                    puts 'Warning: row ' + i.to_s + 
                        ' of the payouts return file contains an invalid recon_token: ' + 
                        row["recon_token"] + ' and has been ignored.'
                    valid_record = false
                end

                # Verify that the currency value is only 3 alpha characters
                if row["currency"].length != 3 || !row["currency"].count("^a-zA-Z").zero? ||
                    !@currency_array.include?(row["currency"].downcase)
                    puts 'Warning: row ' + i.to_s + 
                        ' of the payouts return file contains an invalid currency: ' + 
                        row["currency"] + ' and has been ignored.'
                    valid_record = false
                end

                # Verify that the amount value is a valid integer
                if row["amount"] != "#{row["amount"].to_i}"
                    puts 'Warning: row ' + i.to_s + 
                       ' of the payouts return file contains an invalid amount: ' + 
                        row["amount"] + ' and has been ignored.'
                    valid_record = false
                end

                # Verify that the return reason code is only 3 numerals
                if row["return_reason_code"].length != 3 || 
                    !row["return_reason_code"].count("^0-9").zero?

                    puts 'Warning: row ' + i.to_s + 
                        ' of the payouts return file contains an invalid return reason code: ' + 
                        row["return_reason_code"] + ' and has been ignored.'
                    valid_record = false
                end

                if valid_record
                    # Validation passed, create the PayoutReturn object
                    @payout_returns[ row["recon_token"] ] = PayoutReturn.new( row["post_date"], 
                        row["recon_token"], row["currency"], row["amount"], row["return_reason_code"])
                end
            end

        rescue => err
            # Handle any file related errors
            puts "Error encountered: #{err}"
            err
        end
    end

    def output(recon_token_array)
        # For each recon_token requested, verify a matching record is loaded (and return the 
        # properply formatted record), or return an error

        recon_token_array.each do |recon_token|
            if @payout_returns.has_key?(recon_token)
                @payout_returns[recon_token].output
            else
                puts 'Warning: no return record found for recon_token: ' + recon_token
            end
        end
        
    end

    def all_currencies(hash)
        # Convert a hash list of values to a string array of keys
        hash.keys.to_s
    end

end

