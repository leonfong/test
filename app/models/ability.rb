class Ability
  include CanCan::Ability

  def initialize(user)
    
    # Define abilities for the passed in user here. For example:
    #
    #user ||= User.new # guest user (not logged in)
    alias_action :update, :to => :work_up
    alias_action :update, :to => :work_a          #吴莎4
    alias_action :update, :to => :work_b          #交期5
    alias_action :update, :to => :work_c          #生产6
    alias_action :update, :to => :work_d          #工程7
    alias_action :update, :to => :work_e          #业务8  
    alias_action :update, :to => :work_f          #跟单9
    alias_action :update, :to => :work_g          #采购10
    alias_action :update, :to => :work_baojia          #报价
    alias_action :update, :to => :work_g_all      #采购主管16
    alias_action :update, :to => :work_g_a        #采购1 17
    alias_action :update, :to => :work_g_b        #采购2 18
    alias_action :update, :to => :work_g_c        #采购3
    alias_action :update, :to => :work_g_d        #采购4
    alias_action :update, :to => :work_h          #工时
    alias_action :update, :to => :work_i          #MPN
    alias_action :update, :to => :pcb_review      #PCB_R
    alias_action :update, :to => :pcb_dc          #PCB_DC
    alias_action :update, :to => :old_bom         #老bom匹配功能
    alias_action :update, :to => :external_access         #外部访问21
    alias_action :update, :to => :work_top         #管理员
    alias_action :update, :to => :work_pcb_business          #PCB业务
    alias_action :update, :to => :work_suppliers    #供应商
    alias_action :update, :to => :work_send_to_sell    #发给业务    
    if user.has_role?(:admin)
      #can :manage, :all
      can :work_a, :all
      can :work_top, :all
      #can :work_b, :all
      #can :work_c, :all
      #can :work_d, :all
      can :pcb_review, :all
      can :pcb_dc, :all
      can :work_up, :all
      can :old_bom, :all
      can :work_baojia, :all
      can :work_g_all, :all
      can :work_g, :all
      can :work_e, :all
      can :external_access, :all
      can :work_pcb_business, :all
      can :work_suppliers, :all
      can :work_send_to_sell, :all
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
      #can :work_baojia, :all
      can :old_bom, :all
    elsif user.has_role?(:work_four_a)
      #can :manage, :all
      can :work_up, :all
      can :work_d, :all
      can :work_baojia, :all
      can :work_g_all, :all
      can :old_bom, :all
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
      can :work_baojia, :all
      can :old_bom, :all
      can :work_pcb_business, :all
    elsif user.has_role?(:work_seven_all)
      can :work_send_to_sell, :all
      #can :manage, :all
      can :work_up, :all
      can :work_g, :all
      can :work_baojia, :all
      can :work_g_all, :all
      can :work_suppliers, :all
      can :old_bom, :all
      can :work_pcb_business, :all
    elsif user.has_role?(:work_seven_a)
      #can :manage, :all
      can :work_up, :all
      can :work_g, :all
      can :work_baojia, :all
      can :work_g_a, :all
      can :old_bom, :all
      can :work_pcb_business, :all
    elsif user.has_role?(:work_seven_b)
      #can :manage, :all
      can :work_up, :all
      can :work_g, :all
      can :work_baojia, :all
      can :work_g_b, :all
      can :old_bom, :all
      can :work_pcb_business, :all
    elsif user.has_role?(:work_seven_c)
      #can :manage, :all
      can :work_up, :all
      can :work_g, :all
      can :work_baojia, :all
      can :work_g_c, :all
      can :old_bom, :all
      can :work_pcb_business, :all
    elsif user.has_role?(:work_seven_d)
      #can :manage, :all
      can :work_up, :all
      can :work_g, :all
      can :work_g_d, :all
      can :old_bom, :all
      can :work_pcb_business, :all
    elsif user.has_role?(:work_eight)
      #can :manage, :all
      can :work_up, :all
      can :work_h, :all
    elsif user.has_role?(:work_nine)
      #can :manage, :all
      can :work_i, :all
    elsif user.has_role?(:work_ten)
      #can :manage, :all
      can :work_i, :all
      can :work_up, :all
      can :work_e, :all
    elsif user.has_role?(:work_pcb_review)
      can :pcb_review, :all
    elsif user.has_role?(:work_pcb_dc)
      can :pcb_dc, :all
    elsif user.has_role?(:work_external)
      can :external_access, :all
    elsif user.has_role?(:work_pcb_business)
      can :work_up, :all
      can :work_e, :all
      can :work_pcb_business, :all
      can :work_top, :all
    elsif user.has_role?(:work_suppliers)
      can :work_suppliers, :all
      #can :read, :all
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
