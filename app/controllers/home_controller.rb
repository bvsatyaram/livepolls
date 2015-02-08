class HomeController < ApplicationController
  def index
  end

  def poll
  end

  def load_poll
    @users = User.all.collect(&:for_json).to_json
  end
end
