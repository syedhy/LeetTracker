require 'xcodeproj'

project_path = 'LeetTracker.xcodeproj'
project = Xcodeproj::Project.open(project_path)

if project.targets.find { |t| t.name == 'LeetTrackerTests' }
  puts "Target LeetTrackerTests already exists"
  exit 0
end

main_target = project.targets.find { |t| t.name == 'LeetTracker' }
test_target = project.new_target(:unit_test_bundle, 'LeetTrackerTests', :osx, '14.0')

test_group = project.main_group.find_subpath('LeetTrackerTests', true)
test_group.set_source_tree('<group>')
test_group.set_path('LeetTrackerTests')

test_target.add_dependency(main_target)

test_target.build_configurations.each do |config|
  config.build_settings['TEST_HOST'] = "$(BUILT_PRODUCTS_DIR)/LeetTracker.app/Contents/MacOS/LeetTracker"
  config.build_settings['BUNDLE_LOADER'] = "$(TEST_HOST)"
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.hyder.LeetTrackerTests"
  config.build_settings['PRODUCT_MODULE_NAME'] = "LeetTrackerTests"
  config.build_settings['PRODUCT_NAME'] = "LeetTrackerTests"
  config.build_settings['SWIFT_VERSION'] = "5.0"
  config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = "14.0"
  config.build_settings['GENERATE_INFOPLIST_FILE'] = "YES"
end

Dir.glob('LeetTrackerTests/*.swift').each do |file_path|
  file = test_group.new_file(File.basename(file_path))
  test_target.source_build_phase.add_file_reference(file)
end

project.save

scheme_path = File.join(project_path, 'xcshareddata', 'xcschemes', 'LeetTracker.xcscheme')
if File.exist?(scheme_path)
  scheme_content = File.read(scheme_path)
  unless scheme_content.include?('LeetTrackerTests')
    testable_xml = <<-XML
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "#{test_target.uuid}"
               BuildableName = "LeetTrackerTests.xctest"
               BlueprintName = "LeetTrackerTests"
               ReferencedContainer = "container:LeetTracker.xcodeproj">
            </BuildableReference>
         </TestableReference>
XML
    scheme_content.sub!(/<Testables>\s*<\/Testables>/m, "<Testables>\n#{testable_xml}      </Testables>")
    File.write(scheme_path, scheme_content)
  end
end
