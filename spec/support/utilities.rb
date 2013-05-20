# def full_title(page_title)
 #	base_title = "Ruby on Rails Tutorial Sample App"
 #   if page_title.empty?
  #    base_title
   # else
    #  "#{base_title} | #{page_title}"
    #end
 # end	

# replaced with this in 5.6 exercise 3 

include ApplicationHelper

def valid_signin(user)
	fill_in "Email",	with: user.email
	fill_in "Password",	with: user.password
	click_button "Sign In"
end

# switched to this one in listing 9.5 (section 9.1.1)
def sign_in(user)
	visit signin_path
	fill_in "Email",	with: user.email
	fill_in "Password",	with: user.password
	click_button "Sign In"
	# Sign in when not using Capybara as well
	cookies[:remember_token] = user.remember_token
end

RSpec::Matchers.define :have_error_message do |message|
	match do |page|
		page.should have_selector('div.alert.alert-error', text: message)
	end
end

RSpec::Matchers.define :have_success_message do |message|
	match do |page|
		page.should have_selector('div.alert.alert-success', text: message)
	end
end
