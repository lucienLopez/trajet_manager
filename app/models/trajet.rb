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
  RABBITMQ_QUEUE = 'trajet_state_update'

  enum state: {created: 0, started: 1, cancelled: 2}

  validates :code, uniqueness: true, presence: true

  before_validation :generate_code, unless: :code
  before_create :init_state
  after_save :process_state_change, if: :saved_change_to_state?

  private

  def init_state
    self.state = :created
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
      message = "Trajet #{self.id}: state changed from #{state_before_last_save} to #{state}"
      puts message
      send_rabbit_message(message)
    end
  end

  def send_rabbit_message(message)
    conn = Bunny.new(host: 'rabbitmq')
    conn.start

    channel = conn.create_channel
    queue = channel.queue(RABBITMQ_QUEUE, durable: true, auto_delete: false)
    x = channel.default_exchange

    puts "x: #{x.inspect}"
    x.publish(message, routing_key: queue.name)

    conn.close
  end
end
