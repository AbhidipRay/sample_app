require 'spec_helper'

describe "StaticPages" do
  describe "'Home' page" do
    it "should have content 'sample app'" do
      visit("/static_pages/home")
      expect(page).to have_content("Sample App")
    end
  end

  describe "'Help' page" do
    it "should have content 'Help'" do
      visit("/static_pages/help")
      expect(page).to have_content("Help")
    end
  end

  describe "'About' page" do
    it "should have content 'About'" do
      visit("/static_pages/about")
      expect(page).to have_content("About")
    end

    describe "'Contact' page" do
      it "should have content 'Contact'" do
        visit("/static_pages/contact")
        expect(page).to have_content("Contact Us")
      end
    end
  end

  describe "inspect title change" do
    it "should have title as 'Ruby on Rails Tutorial Sample App | Home' on home page" do
      visit("/static_pages/home")
      expect(page).to have_title("Ruby on Rails Tutorial Sample App | Home")
    end

    it "should have title as 'Ruby on Rails Tutorial Sample App | Help' on help page" do
      visit("/static_pages/help")
      expect(page).to have_title("Ruby on Rails Tutorial Sample App | Help")
    end

    it "should have title as 'Ruby on Rails Tutorial Sample App | About Us' on about page" do
      visit("/static_pages/about")
      expect(page).to have_title("Ruby on Rails Tutorial Sample App | About Us")
    end

    it "should have title as 'Ruby on Rails Tutorial Sample App | Contact Us' on about page" do
      visit("/static_pages/contact")
      expect(page).to have_title("Ruby on Rails Tutorial Sample App | Contact Us")
    end
  end
end
