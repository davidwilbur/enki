class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

  has_many :albums
  has_many :pictures

  has_many :statuses
  has_many :user_friendships
  has_many :friends, -> { where user_friendships: { state: 'accepted' }},
                    through: :user_friendships
                                  #conditions: { user_friendships: { state: 'accepted' } }

  has_many :pending_user_friendships, 
                                      -> { where state: 'pending' },
                                      class_name: 'UserFriendship',
                                      foreign_key: :user_id
                                      #conditions: { state: 'pending' }
                                      
  has_many :pending_friends, through: :pending_user_friendships, source: :friend

  has_many :requested_user_friendships, 
                                      -> { where state: 'requested' },
                                      class_name: 'UserFriendship',
                                      foreign_key: :user_id
                                      #conditions: { state: 'pending' }
  has_many :requested_friends, through: :requested_user_friendships, source: :friend

  has_many :blocked_user_friendships, 
                                      -> { where state: 'blocked' },
                                      class_name: 'UserFriendship',
                                      foreign_key: :user_id
                                      #conditions: { state: 'pending' }
                                      
  has_many :blocked_friends, through: :blocked_user_friendships, source: :friend

  has_many :accepted_user_friendships, 
                                      -> { where state: 'accepted' },
                                      class_name: 'UserFriendship',
                                      foreign_key: :user_id
                                      #conditions: { state: 'pending' }
                                      
  has_many :accepted_friends, through: :accepted_user_friendships, source: :friend

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :bio, :length => { :maximum => 200 }
  validates :profile_name, presence: true, uniqueness: true,
  				format: {
  					with: /\A[a-zA-Z0-9_-]+\z/,
  					message: 'Must be formatted correctly.'
  				}
          
  has_attached_file :avatar, styles: {
    large: "800x800>", medium: "300x200>", small: "260x180>", thumb: "80x80#"
  }

  def self.get_gravatars
    all.each do |user|
      if !user.avatar?
        user.avatar = URI.parse(user.gravatar_url)
        user.save
        print "."
      end
    end
  end

  def full_name
  	first_name + " " + last_name
  end

  def to_param
    profile_name
  end

  def to_s
    first_name
  end

  def gravatar_url
    stripped_email = email.strip
    downcased_email = stripped_email.downcase
    hash = Digest::MD5.hexdigest(downcased_email)

    "http://gravatar.com/avatar/#{hash}"
  end

  def has_blocked?(other_user)
    blocked_friends.include?(other_user)
  end

  def self.get_random(current_user)
    current_requests = User.joins("INNER JOIN users
      ON users.id = user_friendships.user_id").where("user_friendships.state = 'requested'
      AND user_friendships.user_id = ?", current_user.id)

    current_requests

    #@user_filter = current_user.user_filter
    #current_user_pid = current_user.profile.id

    #already_rated = current_user.sent_ratings.pluck(:ratee_id)
    #@random_unmatched = Profile.where("profiles.user_id NOT IN (?)", [-1].concat(already_rated))
     #                           .apply_filters(@user_filter, current_user)
     #                           .sample

    #@random_unmatched

  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def self.find_for_facebook_oauth(auth)
  where(auth.slice(:provider, :uid)).first_or_create do |user|
    user.provider = auth.provider
    user.uid = auth.uid
    user.email = auth.info.email
    user.password = Devise.friendly_token[0,20]
    user.first_name = auth.info.first_name
    user.last_name = auth.info.last_name
    user.profile_name = auth.extra.raw_info.username
    user.gender = auth.extra.raw_info.gender
    user.location = auth.info.location
    #user.name = auth.info.name   # assuming the user model has a name
    #user.image = auth.info.image # assuming the user model has an image
  end
end
end
