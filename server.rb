require 'net/http'
require 'nokogiri'
require 'mail'
require 'time'

def get_product_info(url)
  uri = URI(url)
  response = Net::HTTP.get_response(uri)
  
  if response.code == '200'
    doc = Nokogiri::HTML(response.body)
    price_element = doc.css('span.prc-dsc').first
    price = price_element ? price_element.text.strip : 'Fiyat bilgisi bulunamadı'
    
    name_element = doc.css('h1.pr-new-br').first
    name = name_element ? name_element.text.strip : 'Ürün adı bulunamadı'
    
    return price, name
  else
    puts 'Sayfa alınamadı.'
    return nil, nil
  end
end

def clean_text(text)
  text
end

def send_mail(subject, body)
  options = { :address              => "smtp.gmail.com",
              :port                 => 587,
              :user_name            => 'hidden',
              :password             => 'hidden',
              :authentication       => 'plain',
              :enable_starttls_auto => true }

  Mail.defaults do
    delivery_method :smtp, options
  end

  mail = Mail.new do
    from     'hidden'
    to       'hidden'
    subject  subject

    text_part do
      body clean_text(body)
    end

    html_part do
      content_type 'text/html; charset=UTF-8'
      body clean_text(body)
    end
  end

  mail.deliver!
end

def job
  product_url = 'https://www.trendyol.com/xdrive/anka-profesyonel-oyuncu-koltugu-kirmizi-siyah-p-5751554?boutiqueId=61&merchantId=538804'
  price, name_element = get_product_info(product_url)

  if price && name_element
    subject = clean_text(name_element)
    body = "<html><body><h1>#{clean_text(name_element)}</h1><p>#{clean_text("#{price} fiyatıyla Trendyol'da!")}</p><a href='#{product_url}'>Ürünü incelemek için tıklayın.</a></body></html>"
    send_mail(subject, body)
  else
    puts 'Ürün bilgisi alınamadı.'
  end
end

loop do
  job
  sleep(10)
end
