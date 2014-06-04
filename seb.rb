# SEB provides CSV statements with following columns:

# account number | ??? | date | counterparty account | counterparty name | ??? | ??? | D or C for debit/credit | amount (w/ comma) | ??? | ??? | description | 0 | currency | ???

# Freeagent requires CSV statements as follows:

# Date dd/mm/yyyy | amount (2 decimal places, negative or positive) | description

require 'csv'
require 'date'

unless ARGV.length == 1
  puts "Need an input CSV file"
  exit
end

def parse_description(description, counterparty_name)
  output = description.gsub(",", "")
  if counterparty_name != ""
    output = counterparty_name + " " + output if counterparty_name != "SEB"
  end

  output.trim
end

CSV.open(ARGV[0] + ".freeagent", "wb") do |output|
  rowcount = 0

  CSV.foreach(ARGV[0], encoding: "ISO-8859-15:UTF-8",  :col_sep => ";") do |input|
    puts "On line #{rowcount}"
    rowcount += 1

    date        = Date.parse(input[2])
    sign        = input[7] == "D" ? -1 : 1
    amount      = input[8].gsub(",", ".").to_f
    description = parse_description(input[11], input[4])

    row = []
    row << date.strftime("%d/%m/%Y")
    row << (sign * amount).round(2)
    row << description

    output << row
  end
end

