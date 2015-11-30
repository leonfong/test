ThinkingSphinx::Index.define :product, :with => :active_record, :delta => true do
  # fields
  indexes name, :sortable => true
  indexes description
  indexes part_name
  indexes ptype
  indexes package1
  indexes package2

  has prefer, :type => :integer
end
