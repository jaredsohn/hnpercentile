task :import => :environment do
	require 'csv'
	
	csv_text = File.read("db/unique_names.txt")
	csv = CSV.parse(csv_text, :headers => true)
	new_users_count = 0
	i = 0
	csv.each do |col|
		puts i.to_s() + ":" + col[0]
		member = Member.get_member(col[0])
		if not member
			puts "***not found: " + col[0]
			Member.make_from_api(col[0])
			new_users_count += 1
			sleep 4.0
		end
		i += 1
  	end
  	puts "Imported " + new_users_count.to_s() + " new usernames"
end