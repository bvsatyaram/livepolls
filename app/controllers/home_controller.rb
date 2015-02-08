class HomeController < ApplicationController
  def index
  end

  def poll
  end

  def load_poll
    load_users_json
  end

  def vote
    @user = User.find(params[:user_id])
    current_user.update_attribute(:voted_for_id, @user.id)
    load_users_json
  end

  private

    def load_users_json
      @users_json = User.all_json
    end
end
