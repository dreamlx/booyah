class User < ActiveRecord::Base
  attr_accessible :cell, :email, :name, :password

  validates :email, :uniqueness => {:message => 'That email has already been taken'}, 
    :presence => {:message => "Email is required"}
  validates_format_of :email, :with => /^[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+$/, :message => "That is not a valid email" 
  validate :name_must_have_first_and_last
  validate :cell_must_be_numeric_only
  validates :cell, :uniqueness => {:message => "Someone has already taken that cell phone number"}, 
    :presence => {:message => "Cell phone number is required"}, 
    :length =>  {:is => 14, :message => "That is not a valid phone length"}

  has_secure_password

  has_many :addresses
  has_many :orders
  has_many :paypal_preapprovals
  has_many :credits

  before_create :format_cell

  def cell_must_be_numeric_only
    if cell != nil
      fixed_cell = cell.gsub(/\(/,'').gsub(/\)/,'').gsub(/\s/,'').gsub(/-/,'')
      if fixed_cell.match(/\D/)
        errors.add(:cell, "Cell phone should only contain digits")
      end
    end
  end

  def formatted_name
    name.split(' ').map{|name| name.capitalize}.join(' ')
  end

  def name_must_have_first_and_last
    if name == nil
      errors.add(:name, "Name must be provided")      
    elsif name.split(' ').count < 2
      errors.add(:name, "Must provide first and last name")
    elsif name.split(' ').count > 2
      errors.add(:name, "Only first and last name are needed")
    end
  end

  def default_address
    p "in the default_address method. Here are all possible addresses"
    p addresses
    p "here is the one with default"
    p addresses.where(:default => true).first
    addresses.where(:default => true).first
  end

  def get_receiver(message)
    name = message.downcase.gsub!(/#{ENV['MAIN_KEYWORD']}/, '')
    if name == nil
      p "name is nill"
      return default_address if default_address
      p "went over default address"
      return false
    end
    p "bypassed the name == 1 conditional: here is the name"
    p name
    return 'people' if name.strip == 'people'
    address_by_name = addresses.where(:name => name.strip).first
    return address_by_name if address_by_name
    address_by_keyword = addresses.where(:keyword => name.strip).first
    return address_by_keyword if address_by_keyword
    false 
  end

  def get_all_contacts
    addresses.map{|address| address.formatted_name}.join(', ')
  end

  def make_credit_transaction(amount, description)
    credit = Credit.create(
      :amount => amount,
      :description => description
    )
    credits << credit
  end

  def available_credits
    credits.sum('amount')
  end

  def format_cell
    self.cell = 1.to_s + cell.gsub(/\D/,'').to_s
  end

  def preapproval
    paypal_preapprovals.where("active = true").first
  end

  def first_name
    name.split(' ')[0].capitalize
  end

  def last_name
    name.split(' ')[1].capitalize
  end

  def address
    addresses.first
  end

  def account_active?
    address && preapproval ? true : false
  end
end
