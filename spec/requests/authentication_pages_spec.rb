require 'spec_helper'

describe "Authentication" do 
	
	subject { page }

	describe "signin page" do
		before { visit signin_path }

		it { should have_selector( 'h1', text: 'Sign In') }
		it { should have_selector('title', text: full_title('Sign In'))}

		it { should_not have_link('Users')}
		it { should_not have_link('Profile') }
		it { should_not have_link('Settings') }
	end

	describe "signin" do
		before { visit signin_path }	
	
		describe "with invalid information" do
			before { click_button "Sign In"}

			it { should have_selector('title', text: 'Sign In') }	
			it { should have_error_message('Invalid') }

			describe "after visiting another page" do
				before {click_link "Home" }
				it { should_not have_error_message('Invalid') }
			end 
		end

		describe "with valid information" do
			let(:user) { FactoryGirl.create(:user) }
			before { sign_in user }
			
			it { should have_selector('title', text: user.name) }
			
			it { should have_link('Users', 		href: users_path)}
			it { should have_link('Profile', 	href: user_path(user)) }
			it { should have_link('Settings', 	href: edit_user_path(user)) }
			it { should have_link('Sign Out', 	href: signout_path) }
			
			it { should_not have_link('Sign_In', href: signin_path) }

			describe "followed by signout" do
				before { click_link "Sign Out" }
				it { should have_link('Sign In') }
			end	
		end
	end

	describe "authorization" do

		describe "for non-signed-in users" do
			let(:user) { FactoryGirl.create(:user) }

			describe "when attempting to visit a protected page" do
				before do
					visit edit_user_path(user)
					fill_in "Email", 	with: user.email
					fill_in "Password",	with: user.password
					click_button "Sign In"
				end

				describe "after signing in" do

					it "should render the desired protected page" do
						page.should have_selector('title', text: 'Edit User')
					end

					describe "when signing in again" do
						before do
							delete signout_path
							visit signin_path
							fill_in "Email",  	with: user.email
							fill_in "Password",	with: user.password
							click_button "Sign In"
						end

						it "should render the default (profile) page" do
							page.should have_selector('title', text: user.name)
						end
					end
				end
			end

			describe "in the Users controller" do

				describe "visiting the edit page" do
					before { visit edit_user_path(user) }
					it { should have_selector('title', text: 'Sign In') }
				end

				describe "submitting to the update action" do
					before { put user_path(user) }
					specify { response.should redirect_to(signin_path) }
				end

				describe "visiting the user index" do
					before { visit users_path }
					it { should have_selector('title', test: 'Sign In') }
				end
			end
		end

		describe "as wrong user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
			before { sign_in user }

			describe "visiting Users#edit page" do
				before { visit edit_user_path(wrong_user) }
				it { should_not have_selector('title', text: full_title('Edit User')) }
			end

			describe "submitting a PUT request to the Users#update action" do
				before { put user_path(wrong_user) }
				specify { response.should redirect_to(root_path) }
			end
		end

		describe "as signed in user" do
			let(:user) { FactoryGirl.create(:user) }
			before { sign_in user }

			describe "visit new user page" do
				before { visit signup_path }
				it { should_not have_selector('title', text: full_title('Sign Up')) }
				it { should have_selector('h1', text: "Welcome") }
			end

			describe "submitting a create request to the Users#create action" do
				before { post users_path }
				specify { response.should redirect_to(root_path) }
			end

#Wait to implement when fiugure out how to logout in Rspec (Chap 9 ex 6)
#			describe "visit signin page" do
#				before { visit signin_path }
#				it { should_not have_selector('title', text: full_title('Sign In')) }
#				it { should have_selector('h1', text: "Welcome") }
#			end

		end


		describe "as non-admin user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:non_admin) { FactoryGirl.create(:user) }

			before { sign_in non_admin }

			describe "submitting a DELETE request to the Users#destroy action" do
				before { delete user_path(user) }
				specify { response.should redirect_to(root_path) }
			end
		end

	end

end