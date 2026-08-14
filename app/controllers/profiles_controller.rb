class ProfilesController < ApplicationController
  before_action :require_clerk_user

  def show
    @user = current_user
    @clerk_user = clerk.user
  end
end
