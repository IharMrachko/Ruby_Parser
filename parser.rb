require 'open-uri'
require 'nokogiri'
require 'csv'

urlName = ARGV.first
fileName = ARGV.last
mainPage = Nokogiri::HTML(open(urlName))
allProducts = []
mainPage.css('li.ajax_block_product').each do |product|
  allProducts << product.css('div.pro_first_box').css('a.product_img_link').at('a')['href']
end
CSV.open(fileName, "wb") do |csvLine|
  csvLine << ['Название', 'Цена', 'Изображение']
  allProducts.each do |productUrl|
    productPage = Nokogiri::HTML(open(productUrl))
    productName = productPage.css('h1.product_main_name').css('h1 > text()').to_s
    productImg = productPage.css('span#view_full_size').css('img#bigpic').at('img')['src']
    productPage.css('fieldset.attribute_fieldset').css('ul.attribute_radio_list').each do |attr|
      attr.css('label.label_comb_price').each do |li|
        productPacking = li.css("span.radio_label").text
        productPrice = li.css('span.price_comb').text
        fullInfo = ["#{productName} - #{productPacking}", productPrice, productImg]
        csvLine << fullInfo
      end
    end
  end
end