require 'spec_helper'

describe User do
  let!(:user) { User.new(name: "Abhidip", email: "aray@kreeti.com",
                         password: "03324221898", password_confirmation: "03324221898") }
  subject { user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:remember_token) }
  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
    before do
      user.save!
      user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "name not present" do
    before { user.name = "" }

    it { should_not be_valid }
  end

  describe "email not present" do
    before { user.email = "" }

    it { should_not be_valid }
  end

  describe "name too long" do
    before { user.name = user.name * 50 }

    it { should_not be_valid }
  end

  describe "email format wrong" do
    before { user.email = "abc@example" }

    it { should_not be_valid }
  end

  describe "email has already been taken" do

    before do
      user.save!
      @new_user = user.dup
      @new_user.save
    end

    it "should have invalid duplicate email" do
      expect(@new_user).not_to be_valid
    end
  end

  describe "with a password that's too short" do
    before { user.password = user.password_confirmation = "A" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { user.save }
    let(:found_user) { User.find_by(email: user.email) }

    describe "with valid password" do
      it { should eq found_user.authenticate(user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end

  describe "when password is not present" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
                       password: " ", password_confirmation: " ")
    end

    it "has blank password" do
      expect(@user).not_to be_valid
    end
  end

  describe "when password doesn't match confirmation" do
    before { user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "remember token" do
    before { user.save }
    its(:remember_token) { should_not be_blank }
  end
end
