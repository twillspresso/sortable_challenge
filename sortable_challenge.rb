#!/usr/bin/ruby
require 'rubygems'
require 'json'

listings, products, manufacturers, models, families, results = Array.new(6) { [] }

# INPUT
text = File.open('products.txt').read
text.gsub!(/\r\n?/, "\n") # Fix line endings for unix/windows
# Get each json object and downcase relevent fields, for uniform strings
# Creates an array of product JSONs
text.each_line do |line|
  json = JSON.parse line
  json['product_name'].downcase!
  json['model'].downcase! unless json['model'].nil?
  json['manufacturer'].downcase!
  json['family'].downcase! unless json['family'].nil?
  products.push(json)

  # Create separate arrays for a manufacturer, model and family list
  manufacturers.push(json['manufacturer'])
  models.push(json['model'])
  families.push(json['family'])
end

# Get rid of duplicate model/manufacturer entries
manufacturers.uniq!
models.uniq!
families.uniq!

# Read in listings and downcase relevent fields
# Creates an array of listing JSONs
text = File.open('listings.txt').read
text.gsub!(/\r\n?/, "\n") # Fix line endings for unix/windows
text.each_line do |line|
  json = JSON.parse line
  json['title'].downcase!
  json['manufacturer'].downcase!
  listings.push(json)
end

# PRE-PROCESSING
# Prune irrlevent or uncertain listings
puts('Listing count before pruning: ', listings.length)

listings.each do |listing|
  # Pop any listings that include multiple manufactuerers
  # or don't have a manufacturer in the product list
  listing_manufacturers = manufacturers.select do |manufacturer|
    listing['manufacturer'].include?(manufacturer)
  end
  listings.delete(listing) unless listing_manufacturers.length == 1

  # Pop any listings that include multiple models
  listing_models = models.select do |model|
    listing['title'].include?(' ' + model + ' ')
  end
  listings.delete(listing) if listing_models.length > 1
end

puts('Listing count after pruning: ', listings.length)

# Despite having no manufacturer field the listing can still be valid
# But we'll display to user so they understand dataset better (ie. less certain)
puts 'Warning: NM' if listings.any? { |listing| listing['manufacturer'].nil? }

# MAIN SEARCH
# Loop through all the listings to find a potential product match
listings.each do |listing|
  maker = manufacturers.find do |manufacturer|
    listing['manufacturer'].include?(manufacturer)
  end
  unless maker.nil?
    # Search product listings that have the same manufacturer as the listing
    product_subset = products.select do |product|
      product['manufacturer'].include?(maker)
    end
    # Create array of possible products that match the listing
    possible_products = []
    product_subset.each do |product|
      unless product['family'].nil?
        # If all three fields match, we're fairly certain, add it to possibles
        if listing['title'].include?(' ' + product['model'] + ' ') &&
           listing['title'].include?(' ' + product['family'] + ' ')
          possible_products << product
        end
      end
    end
    # Check if we have more than one product, if not append product and listing
    if possible_products.length > 1
      puts 'WARNING: More than one possible product, ignoring listing'
    elsif possible_products.length == 1
      # If our result array already contains this product add listing to array
      if existing_result_index = results.find_index do |result|
        result['product_name'] == possible_products[0]['product_name']
      end
        results[existing_result_index]['listings'].push(listing)
      # Otherwise create new result array entry for product
      else
        results << { 'product_name' => possible_products[0]['product_name'],
                     'listings' => [listing] }
      end
    end
  end
end

# OUTPUT
# Output results and format for JSON lines
output = File.open('results.txt', 'w')
results.each do |result|
  output.puts result.to_s.gsub!('=>', ':')
end
