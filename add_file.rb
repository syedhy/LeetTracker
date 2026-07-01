require 'xcodeproj'
project_path = 'LeetTracker.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'LeetTracker' }
group = project.main_group.find_subpath('LeetTracker', true)
file = group.new_reference('BackgroundRefreshManager.swift')
target.add_file_references([file])
project.save
