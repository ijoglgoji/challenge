# Instructions to run
1. git clone <repo>
2. cd <repo>
3. bundle install
4. rubocop -a (for linting)
5. rspec -fd (for specs)
6. ruby main.rb -f "./sample_csv.txt" -t 10 -s 10
   to try it out with the sample file

# Issues with the assignment
1. Specs are not complete
2. We could have used a single cache to store the timestamps
   across the HitsMonitor and AlertsMonitor
3. This single program wont currently work for static file and tailed realtime file
4. The ending timestamps of the files are not being handled well yet.
5. The assignment could have had been dockerized
6. Documentation could have had been improved

