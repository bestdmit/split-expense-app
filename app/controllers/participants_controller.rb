class ParticipantsController < ApplicationController
  before_action :require_login
  before_action :set_participant, only: :destroy

  def index
    @participants = current_user.participants.order(:name)
    @participant = current_user.participants.new
  end

  def create
    @participant = current_user.participants.new(participant_params)
    if @participant.save
      redirect_to participants_path, notice: "Участник добавлен"
    else
      @participants = current_user.participants.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @participant.destroy
    redirect_to participants_path, notice: "Участник удалён"
  end

  private

  def participant_params
    params.require(:participant).permit(:name)
  end

  def set_participant
    @participant = current_user.participants.find(params[:id])
  end
end
