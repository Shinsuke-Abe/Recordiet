# encoding: utf-8
require 'bcrypt'

class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :display_name, :mail_address, :height, :password_digest, :password, :is_administrator, :twitter_link_flag, :hash_tag

  validates :mail_address, :display_name, :password, :presence => true
  validates :mail_address, :uniqueness => true, :email_format => true
  validates :height, :numericality => {greater_than_or_equal_to: 0.1}, :allow_blank => true
  validate :twitter_link_flag_and_hash_tag_relativity

  has_many :weight_logs, :dependent => :destroy
  has_many :achieved_milestone_logs, :dependent => :destroy
  has_one :milestone, :dependent => :destroy

  before_save :encrypt_password

  def self.authenticate(mail_address, password)
    if user = User.find_by_mail_address(mail_address)
      user_password = BCrypt::Password.new(user.password_digest)

      user_password == password ? user : nil
    else
      user
    end
  end

  def encrypt_password
    if password.present?
      self.password_digest = BCrypt::Password.create(password)
    end
  end

  def latest_weight_log
    weight_logs.first
  end

  def latest_weight_log_has_fat_percentage
    WeightLog.find_latest_log_has_fat_precentage(self)
  end

  def weight_to_milestone
    if milestone and milestone.weight and latest_weight_log
      (latest_weight_log.weight - milestone.weight).round(2)
    end
  end

  def days_to_milestone
    if milestone and milestone.weight
      (milestone.date - Date.today).to_i
    end
  end

  def fat_percentage_to_milestone
    if milestone and milestone.fat_percentage and latest_weight_log_has_fat_percentage
      (latest_weight_log_has_fat_percentage.fat_percentage - milestone.fat_percentage).round(2)
    end
  end

  def bmi
    if latest_weight_log and height
      (latest_weight_log.weight / ((height / 100) ** 2)).round(1)
    end
  end

  @@ponderal_index_types = {
    1 => "やせ型",
    2 => "標準",
    3 => "肥満(肥満度1)",
    4 => "肥満(肥満度2)",
    5 => "肥満(肥満度3)",
    6 => "肥満(肥満度4)"
  }.freeze

  def ponderal_index
    if bmi
      if bmi < 18.5
        1
      elsif (18.5...25).include? bmi
        2
      elsif (25...30).include? bmi
        3
      elsif (30...35).include? bmi
        4
      elsif (35...40).include? bmi
        5
      elsif bmi >= 40
        6
      end
    end
  end

  def display_ponderal_index
    @@ponderal_index_types[ponderal_index]
  end

  def twitter_link_flag_and_hash_tag_relativity
    if twitter_link_flag and hash_tag.blank?
      errors.add(:hash_tag, "can't blank when twitter_link_flag is true")
    end
  end
end
