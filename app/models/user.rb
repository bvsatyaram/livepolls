class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :trackable, :validatable
  devise :rememberable, :trackable, :omniauthable, :omniauth_providers => [:facebook]

  belongs_to :voted_for, class_name: User.name, counter_cache: :voters_count
  has_many :voters, class_name: User.name, foreign_key: :voted_for_id, dependent: :nullify

  after_create :publish_to_pubnub
  after_save :publish_to_pubnub_if_voted

  def for_json
    json = for_json_without_votes
    json[:votes] = voters.collect(&:for_json_without_votes)

    return json
  end
  def for_json_without_votes
    {
      id: id,
      name: name,
      image: image
    }
  end

  class << self
    def from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.email = auth.info.email
        user.name = auth.info.name
        user.image = auth.info.image
      end
    end

    def new_with_session(params, session)
      super.tap do |user|
        if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
          user.email = data["email"] if user.email.blank?
        end
      end
    end

    def publish_to_pubnub
      pubnub_channel.publish(
        channel: "live-polls",
        message: User.all_json,
        callback: pubnub_callback
      )
    end

    def all_json
      order(voters_count: :desc).collect(&:for_json).to_json
    end
  end

  private

    def publish_to_pubnub_if_voted
      publish_to_pubnub if voted_for_id_changed?
    end

    def publish_to_pubnub
      User.publish_to_pubnub
    end

    class << self
      def pubnub_channel
        Pubnub.new(
         :publish_key   => ENV['PUBNUB_PUBLISH_KEY'],
         :subscribe_key => ENV['PUBNUB_SUBSCRIBE_KEY'],
         :uuid => 'live-polls-server'
         )
      end

      def pubnub_callback
        lambda {}
      end
    end
end
