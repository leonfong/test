# admin 管理员
# work_eleven 财务
# work_four_bom BOM管理
# work_five 业务
['admin', 'work_eleven', 'work_four_bom', 'work_five'].each do |role|
  Role.find_or_create_by({name: role})
end