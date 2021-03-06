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
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }
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

  describe "micropost assosiations" do
    before { user.save! }
    let!(:older_micropost) { FactoryGirl.create(:micropost, user: user, created_at: 1.day.ago) }
    let!(:newer_micropost) { FactoryGirl.create(:micropost, user: user, created_at: 1.hour.ago) }

    it "should have microposts in order of recent created" do
      expect(user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it "should destroy assosiated microposts" do
      microposts = user.microposts.to_a
      user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
      end

      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
    end
  end

  describe "following" do
    let!(:other_user) { FactoryGirl.create(:user) }
    before do
      user.save!
      user.follow!(other_user)
    end

    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }

    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(user) }
    end

    describe "and unfollowing" do
      before{ user.unfollow!(other_user) }

      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end
  end
end
