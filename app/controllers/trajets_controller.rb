class TrajetsController < ApplicationController
  def create
    trajet = Trajet.create

    render json: {code: trajet.code}
  end

  def start
    trajet = Trajet.find_by_code(params[:code])
    if trajet.update(state: :started)
      head :ok
    else
      head :internal_server_error
    end
  end

  def cancel
    trajet = Trajet.find_by_code(params[:code])
    if trajet.update(state: :cancelled)
      head :ok
    else
      head :internal_server_error
    end
  end
end
