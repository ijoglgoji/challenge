# frozen_string_literal: true
# NOT USED ANYMORE
#
# # frozen_string_literal: true
#
# def main
#   urls = [
#     '/api/user',
#     '/api/',
#     '/api/story',
#     '/report',
#     '/report/user'
#   ]
#
#   filename = ARGV[0]
#
#   File.open(filename, 'w') do |f|
#     timestamp = 1_549_573_860
#     loop do
#       10.times do
#         f.puts("'10.0.0.2','-','apache',#{timestamp},'GET #{urls.sample} HTTP/1.0',200,1234")
#       end
#       sleep(1)
#       timestamp += 1
#     end
#   end
# end
#
# main
