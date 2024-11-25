class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def party
    @party = Party.find(params[:id])
  end

  def result
    @result = Result.find(params[:id])
  end
end
