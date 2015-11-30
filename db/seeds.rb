# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


parts = Part.create([{part_code: 'IC', part_name: 'chips'},{part_code: 'LED', part_name: 'led'},{part_code: 'RB', part_name: 'resistor'}])


products = Product.create([{name: 'A.U.2261-SOICB',description: 'IC UCS1903B SOIC8 SMD UCS',price: 1000},{name: 'A.LE.01.0080-SMD',description: '红绿蓝灯 SMD PLCC-6 5050 RGB',price: 10000},{name: 'A.3.R.0394-0805',description: '电阻 270R±1% 0805 ROYALOHM',price: 1000}])