class User < ActiveRecord::Base
  has_many :pi_infos
  has_many :setup_finance_infos
  has_many :bank_infos
  has_many :pay_types
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
end
