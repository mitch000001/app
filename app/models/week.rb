class Week
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  # belongs_to :user
  # has_many :timers
  # has_and_belongs_to_many :tasks

  attr_accessor :timers

  #accepts_nested_attributes_for :timers, allow_destroy: true

  # before_save :reject_empty_timers

  # def reject_empty_timers
  #   timers.each do |timer|
  #     timer.destroy if timer.value.empty?
  #   end
  # end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

end
