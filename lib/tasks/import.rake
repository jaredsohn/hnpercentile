task :import => :environment do
	require 'csv'    

	csv_text = File.read("db/unique_names.txt")
	csv = CSV.parse(csv_text, :headers => true)
	count = 0
	csv.each do |col|
		member = Member.get_member(col[0])
		if not member
			Member.make_from_api(col[0])
			count++
			sleep 1.0
		end
  	end
  	puts "Imported " + count.to_s() + " new usernames"
end