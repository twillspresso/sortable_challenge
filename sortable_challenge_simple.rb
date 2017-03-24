#!/usr/bin/ruby
require 'rubygems'
require 'json'

listings = []
products = []
results = []

text = File.open('products.txt').read
text.gsub!(/\r\n?/, "\n")
text.each_line do |line|
  json = JSON.parse line
  products.push(json)
end

text = File.open('listings.txt').read
text.gsub!(/\r\n?/, "\n")
text.each_line do |line|
  json = JSON.parse line
  listings.push(json)
end

products.each do |product|
  result_listings = []
  listings.each do |listing|
    if listing['title'].include?(product['manufacturer']) && listing['title'].include?(product['model'])
      result_listings.push(listing)
    end
  end
  unless result_listings.nil?
    results.push(product_name: product['product_name'], listings: result_listings)
  end
end

output = File.open('results.txt', 'w')
output.puts(results)
