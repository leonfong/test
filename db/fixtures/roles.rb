# admin 管理员
# work_eleven 财务
# work_four_bom BOM管理
# work_five 业务
# work_g_admin 采购主管
# work_five_admin 业务主管
['admin', 'work_eleven', 'work_four_bom', 'work_five', 'work_g_admin', 'work_five_admin'].each do |role|
  Role.find_or_create_by({name: role})
end