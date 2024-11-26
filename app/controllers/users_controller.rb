class UsersController < ApplicationController
  # before_action :set_user, only: :update

  def update
    if current_or_guest_user.update(user_params)
      redirect_to parties_path, notice: "Bravo"
    else
      render "pages/home", status: :unprocessable_entity
    end
  end

  private


  def user_params
    params.require(:user).permit(:username)
  end
end
