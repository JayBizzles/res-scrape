require 'nokogiri'
require 'httparty'
require 'byebug'
require 'awesome_print'
require 'watir'

def input #takes user input and grabs the url for that particular search

  puts "1) Enter the job title that you want to search for \n"
  j_input = gets.chomp
  job = j_input.split(/ /).join("+")
  puts "================================= \n"

  puts "1/2)Do you want to input city-and-state(1) or zipcode(2)? \n"
  choice = gets.chomp

  if choice == "1"

    puts "2) Enter the city that you want to search for \n"
    city_input = gets.chomp
    city = city_input.split(/ /).join("+")
    puts "================================= \n"

    puts "3) Enter the state that you want to search for \n"
    state_input = gets.chomp
    state = "+" + state_input
    puts "========================================= \n"

    puts "Do you want to search the resumes for their job title (jt)/skills (sk)/ or field of study (fos)?" # gonna have to move this up so that I can get the appropriate link for what they are searching for
  	 search_choice = gets.chomp

   if search_choice == "jt"
		puts target_url = "https://www.indeed.com/resumes/?q=#{job}&l=#{city}%2C#{state}&cb=jt"
  	

  	elsif search_choice == "sk"
 	 	puts target_url = "https://www.indeed.com/resumes/?q=#{job}&l=#{city}%2C#{state}&cb=skills"
   

  	elsif search_choice == "fos"
  		puts target_url = "https://www.indeed.com/resumes/?q=#{job}&l=#{city}%2C#{state}&cb=jt"
 	

   else
		puts "Error"
	end

   elsif choice == "2"

   	puts "Enter the zipcode that you want to search for \n"
   	zipcode = gets.chomp

   	puts "Do you want to search the resumes for their job title (jt)/skills (sk)/ or field of study (fos)?" # gonna have to move this up so that I can get the appropriate link for what they are searching for
  		search_choice = gets.chomp

  		if search_choice == "jt"
			puts target_url = "https://www.indeed.com/resumes?q=#{job}&l=#{zipcode}&cb=#{search_choice}"
  		

  		elsif search_choice == "sk"
 	 		puts target_url = "https://www.indeed.com/resumes?q=#{job}&l=#{zipcode}&cb=#{search_choice}"
   	

  		elsif search_choice == "fos"
  			puts target_url = "https://www.indeed.com/resumes?q=#{job}&l=#{zipcode}&cb=#{search_choice}"
   	
	end

  else
    puts "error"
  end

  unparsed_page = HTTParty.get(target_url)
  parsed_page = Nokogiri::HTML(unparsed_page)
  resume_listing = parsed_page.css('div.sre-content')
  per_page = resume_listing.count
  resumes = Array.new
  counter = 0
  result_count = parsed_page.css('div#result_count').text.split(' ')[0].gsub(',','').to_i
  page_count = (result_count.to_f / per_page.to_f ).ceil
  current_count = 0 

  else

    while current_count <= page_count * per_page && counter <= page_count
    	if current_count == 0 && counter == 0 
    		pagination_url = target_url
    		unparsed_pagination_page = HTTParty.get(pagination_url)
    		pagination_parsed_page = Nokogiri::HTML(unparsed_pagination_page)
    		pagination_resume_listing = pagination_parsed_page.css('div.app_name')
    		pagination_resume_listing.each do |resume_listing|
    			resume_info = {
    				title: resume_listing.css('a.app_link').text,
    				link: "https://www.indeed.com" + resume_listing.css('a')[0].attributes['href'].text.gsub('?sp=0',''),
    			}
    			resumes << resume_info
    			puts "Added #{resume_info[:title]} Link => #{resume_info[:link]}"
  		  end
    	counter += 1
    	current_count += 50
    	elsif current_count != 0 && counter != 0
      	pagination_url = "https://www.indeed.com/resumes?q=#{job}&l=#{zipcode}&co=US&cb=#{search_choice}&start=#{current_count}"
      	unparsed_pagination_page = HTTParty.get(pagination_url)
      	pagination_parsed_page = Nokogiri::HTML(unparsed_pagination_page)
      	pagination_resume_listing = pagination_parsed_page.css('div.app_name')
      	pagination_resume_listing.each do |resume_listing|

        resume_info = {

          title: resume_listing.css('a.app_link').text,
          link:  "https://www.indeed.com" + resume_listing.css('a')[0].attributes["href"].text.gsub('?sp=0','')
          # skills:
          # education:
        }
        resumes << resume_info

        puts "Added #{resume_info[:title]} Link => #{resume_info[:link]}"
        puts "\n"
      end
      puts "============================================="
      puts "PAGE-#{counter}"
      counter += 1
      current_count += 50
    end
  end
end
input 