class Week < ActiveRecord::Base
  belongs_to :user
  has_many :timers
  has_and_belongs_to_many :tasks
  has_many :projects, through: :tasks

  accepts_nested_attributes_for :timers, allow_destroy: true, reject_if: :reject_timers

  def reject_timers attributes
    exists = attributes['id'].present?
    empty = attributes[:value].blank?
    attributes.merge!({:_destroy => 1}) if exists and empty
    return (!exists and empty)
  end
end
