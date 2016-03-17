class Ability
  include CanCan::Ability

  def initialize(user)
    
    # Define abilities for the passed in user here. For example:
    #
    #user ||= User.new # guest user (not logged in)
    alias_action :update, :to => :work_up
    alias_action :update, :to => :work_a          #吴莎
    alias_action :update, :to => :work_b          #交期
    alias_action :update, :to => :work_c          #生产
    alias_action :update, :to => :work_d          #工程
    alias_action :update, :to => :work_e          #业务
    alias_action :update, :to => :work_f          #跟单
    alias_action :update, :to => :work_g          #采购
    alias_action :update, :to => :work_h          #工时
    alias_action :update, :to => :work_i          #MPN
    if user.has_role?(:admin)
      #can :manage, :all
      can :work_a, :all
      #can :work_b, :all
      #can :work_c, :all
      #can :work_d, :all
      can :work_up, :all
    elsif user.has_role?(:manager)
      can :manage, :all
    elsif user.has_role?(:work_one)
     # can :manage, :all
      can :work_up, :all
      can :work_a, :all
    elsif user.has_role?(:work_two)
      #can :manage, :all
      can :work_up, :all
      can :work_b, :all
    elsif user.has_role?(:work_three)
      #can :manage, :all
      can :work_up, :all
      can :work_c, :all
      can :work_h, :all
    elsif user.has_role?(:work_four)
      #can :manage, :all
      can :work_up, :all
      can :work_d, :all
    elsif user.has_role?(:work_five)
      #can :manage, :all
      can :work_up, :all
      can :work_e, :all
    elsif user.has_role?(:work_six)
      #can :manage, :all
      can :work_up, :all
      can :work_f, :all
    elsif user.has_role?(:work_seven)
      #can :manage, :all
      can :work_up, :all
      can :work_g, :all
    elsif user.has_role?(:work_eight)
      #can :manage, :all
      can :work_up, :all
      can :work_h, :all
    elsif user.has_role?(:work_nine)
      #can :manage, :all
      can :work_i, :all
    else
      can :read, :all
    end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
