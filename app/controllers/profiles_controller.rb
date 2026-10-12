class ProfilesController < ApplicationController
  # Защищённая страница: без входа перекинет на /login
  before_action :require_login

  def show
  end
end
