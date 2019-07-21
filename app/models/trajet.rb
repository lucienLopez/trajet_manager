# == Schema Information
#
# Table name: trajets
#
#  id         :bigint           not null, primary key
#  code       :string
#  state      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_trajets_on_code  (code)
#


class Trajet < ApplicationRecord
  enum state: {created: 0, started: 1, cancelled: 2}

  validates :code, uniqueness: true, presence: true

  before_validation :generate_code, unless: :code
  before_create :set_state
  after_save :process_state_change, if: :saved_change_to_state?

  private

  def set_state
    self.state ||= :created
  end

  def generate_code
    self.code = SecureRandom.alphanumeric(4)
    generate_code if Trajet.exists?(code: self.code)
  end

  def process_state_change
    if created?
      Billing.bill
    elsif started?
      Billing.pay
    else
      Billing.reimburse
    end

    if state_before_last_save
      puts "Trajet #{self.id}: state changed from #{state_before_last_save} to #{state}"
    end
  end
end
