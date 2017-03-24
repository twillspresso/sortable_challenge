# Sortable Challenge

Implemented a simple substring search technique to pair listings with appropriate products

# Requirements
- Ruby 2.3+
- json rubygem

# Usage

## Prerequisites
- Clone git repo
- Install required gems
- Ensure data files are appropriately named (listings.txt, products.txt) and in the same directory

## Run
  cd sortable_challenge
  ruby sortable_challenge.rb

# Methodology

## Initial
  The first method I attempted was a fuzzy string matching algorithm to compare listing titles with product names
  This did not work at all, because a given product title can range from having a lot of extraneous information to being very similar to the product name
  After that a simple substring match was attempted, which resulted in the simple solution alternative file provided.
  This was very easy to solve, and produced "Good Enough" results, in so far as it produced a list of possible listings per product that a human could easily parse and decide which are correct or not.
  For computational needs though, this was far from sufficient, as it did not assign a listing to at most one product, and if the scale was very large it becomes absurd for a human to read.
  I decided to continue with this method, as it was simple and produced good results, but refine it further

## Optimization
  At this point I considered better ways to process the data
  Currently it loops through every listing, and then every product for possible assignment, which is Very Bad because we're going to run in O(n^2) time
  I considered multiple methods of search and sort to try and get this running better, but there isn't a very good way to do this with this type of data
  There's no easy way to order the data to aid later searching, since there's no guarantee the relevant terms will be in any order within the listing title string
  Ultimately I abandoned hope that processing time could be improved without significant loss of recall and precision
  A better solution for a larger scale project would be to build a neural network (ala TensorFlow with Syntaxnet) that learns key words (like manufacturers, models, etc) and maintains a list of these to compare to
  This would significantly save processing time, because you could parse out only the relevant information from listings and order it to assign to products
  But it would only be useful if this was intended to be long-term and repeatedly processed with new data, since it would take time to learn
  I decided that the best approach was to narrow comparison space as best I can given the data I have, which I accomplish in a few ways:
    - A list of product manufacturers is created, and listings are only compared to those products which have the same manufacturer
    - Listings with multiple product models or multiple product manufacturers are discarded, as this is either an accessory for multiple products, or we can't be sure which product it is for
    - Finally if we still have multiple product matches, skip it since we're going for accuracy

# Considerations
  - This is a very slow solution, and will only get worse with larger datasets
  - This is a very thorough solution, we consider every possible match
  - This is an accurate solution, by matching on 3 terms and discarding any listings we have any degree of uncertainty about, we can be confident in our end matches
  - Parallel processing would be an obvious extension of this algorithm to improve runtime significantly
  - The search loop and preprocessing loop can be combined to save significant runtime, but I've left them separate because it would be useful for future code expansion
    - I.e. if this was running against multiple datasets over time, the code could be easily modified to save the model, manufacturer, and family arrays in a database and
      add to them as needed, and do additional preprocessing steps to limit listings as needed

# Potential Pitfalls
  - Because we discard listings that contain multiple model substrings, if any given model name is very common or simple (ie. '5' or 'zoom'), we potentially discard valid product listings that just happen to contain that string
  - Runtime for very large datasets is going to be Very Bad because of previously mentioned O(n^2) problem
