task default: %w[kubespray_install test]

task :test do
  puts `rspec spec`
end

task :install => [:kubespray_install,:manifest_install]

task :kubespray_install do
  puts "Installing kubespray"
  ruby "tasks/kubespray_repo_install.rb"
end

task :manifest_install do
  puts "Installing manifest-tool"
  ruby "tasks/manifest_tool_install.rb"
end



