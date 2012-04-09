load "lib/tasks/blog.rake"

desc "Demo task"
task :demo do
  blogger_id = 'shaobo_wu'
  Rake::Task["blog:fetch"].invoke blogger_id
end

task :default => 'demo'
