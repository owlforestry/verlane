require 'verlane'
require 'versionomy'
require 'yaml'

VERSION = if File.exists?('VERSION.yml')
  Versionomy.create(YAML.load_file('VERSION.yml'))
elsif File.exists?('VERSION')
  Versionomy.parse(File.read('VERSION').strip)
else
  Versionomy.create(major: 0, minor: 0, tiny: 1)
end

def bump_version(version)
  field = case version.release_type
    when :alpha
      :alpha_version
    when :beta
      :beta_version
    when :release_candidate
      :release_candidate_version
    else
      :tiny2
  end
  version.bump(field)
end

def save_version(version)
  ver = if File.exists?('VERSION.yml')
    YAML.load_file('VERSION.yml')
  else
    {}
  end
  ver.merge!(version.values_hash)
  ver[:string] = version.to_s
  ver[:short]  = version.to_s
  
  if File.exists?('VERSION.yml')
    File.open('VERSION.yml', 'w') {|io| io.write ver.to_yaml}
    system "git add VERSION.yml"
    system "git commit VERSION.yml -m 'Bumped version to #{ver[:string]}'"
  else
    File.open('VERSION', 'w') {|io| io.write ver[:string]}
    system "git add VERSION"
    system "git commit VERSION -m 'Bumped version to #{ver[:string]}'"
  end
  
  puts "New version #{ver[:string]}"
end


desc "Print current version #{VERSION.to_s}"
task :version do
  puts "#{VERSION.to_s}"
end

namespace :version do
  desc "Bumps build to next #{bump_version(VERSION).to_s}"
  task :bump do
    save_version(bump_version(VERSION))
  end
  
  namespace :bump do
    VERSION.field_names[0..4].each do |field|
      desc "Bump version to #{VERSION.bump(field).to_s}"
      task field do
        save_version(VERSION.bump(field))
      end
    end
  end
  
  desc "Release version #{VERSION.release.to_s}"
  task :release do
    save_version(VERSION.release)
  end
  
  desc "Prepare for release #{VERSION.bump(:minor).change(release_type: :beta).to_s}"
  task :pre do
    save_version(VERSION.bump(:minor).change(release_type: :beta))
  end
  
  namespace :pre do
    VERSION.field_names[0..2].each do |field|
      desc "Prepare for release #{VERSION.bump(field).change(release_type: :beta).to_s}"
      task field do
        save_version(VERSION.bump(field).change(release_type: :beta))
      end
    end
  end
end
