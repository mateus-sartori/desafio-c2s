class ScrapingService
  class ScrapingError < StandardError; end

  def self.call(url)
    raise ScrapingError, "URL cannot be blank" if url.blank?

    Rails.logger.info "[ScrapingService] Fetching URL: #{url}"

    html = fetch_html(url)
    raise ScrapingError, "Fetched HTML is empty" if html.blank?

    doc = Nokogiri::HTML5(html)

    title_node = doc.at_css(".VehicleDetails__header__title")
    price_node = doc.at_css(".Forms__vehicleSendProposal__container__price")

    raise ScrapingError, "Brand/Model element not found" unless title_node
    raise ScrapingError, "Price element not found" unless price_node

    brand = title_node.text&.strip.split(" ")[0]
    model = title_node.first_element_child.inner_html
    price = price_node.text&.strip

    raise ScrapingError, "Brand/Model text is blank" if brand.blank? && model.blank?
    raise ScrapingError, "Price text is blank" if price.blank?

    {
      brand: brand.split(" ")[0],
      model: model,
      price: price
    }

  rescue ScrapingError, StandardError => e
    Rails.logger.error "[ScrapingService] Error: #{e.class}: #{e.message}"
    raise
  end

  def self.fetch_html(url)
    headless = Headless.new
    headless.start

    browser = Ferrum::Browser.new(
      headless: false,
      browser_path: "/usr/bin/chromium",
      browser_options: {
        "no-sandbox": nil,
        "disable-dev-shm-usage": nil,
        "disable-gpu": nil,
        "disable-setuid-sandbox": nil
      }
    )

    raise ScrapingError, "Browser failed to initialize" unless browser

    browser.go_to(url)
    browser.network.wait_for_idle

    unless browser.at_css("h1.VehicleDetails__header__title")
      raise ScrapingError, "Expected page content not found"
    end

    html = browser.body
    raise ScrapingError, "Browser returned empty body" if html.blank?

    browser.quit
    headless.destroy

    html

  rescue Ferrum::TimeoutError => e
    raise ScrapingError, "Timeout waiting for page content: #{e.message}"
  rescue => e
    raise ScrapingError, "Ferrum error: #{e.message}"
  ensure
    browser&.quit rescue nil
    headless&.destroy rescue nil
  end
end
