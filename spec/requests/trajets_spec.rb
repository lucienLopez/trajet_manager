RSpec.describe 'Trajets', type: :request do
  describe 'POST create' do
    it 'creates new Trajet correctly and returns JSON with its code' do
      expect { post(trajets_path) } .to change { Trajet.count } .from(0).to(1)
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("{\"code\":\"#{Trajet.last.code}\"}")
    end
  end

  describe 'POST start' do
    let(:trajet) { Trajet.create }

    it 'creates trajet correctly' do
      post(start_trajets_path(trajet.code))
      expect(response).to have_http_status(:ok)
      expect(trajet.reload.state).to eq('started')
    end
  end

  describe 'POST cancel' do
    let(:trajet) { Trajet.create }

    it 'cancels trajet correctly' do
      post(cancel_trajets_path(trajet.code))
      expect(response).to have_http_status(:ok)
      expect(trajet.reload.state).to eq('cancelled')
    end
  end
end
