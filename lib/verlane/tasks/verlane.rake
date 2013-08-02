require 'verlane'
require 'versionomy'
require 'yaml'

VERSION = if File.exists?('VERSION.yml')
  yaml = YAML.load_file('VERSION.yml')
  ver = Versionomy.create(yaml)
  if !ver.prerelease? and yaml[:build] and yaml[:build] > ver.tiny2
    ver = ver.change(tiny2: yaml[:build])
  end
  ver
elsif File.exists?('VERSION')
  Versionomy.parse(File.read('VERSION').strip)
else
  Versionomy.create(major: 0, minor: 0, tiny: 1)
end

def bump_version(version, fields = {})
  if fields.empty?
    key = case version.release_type
      when :alpha
        :alpha_version
      when :beta
        :beta_version
      when :release_candidate
        :release_candidate_version
      else
        :tiny2
    end
    fields[key] = true
  end

  build = version.tiny2
  
  new_ver = fields.inject(version) {|version, chg| field, change = chg; change.kind_of?(TrueClass) ? version.bump(field) : version.change(field => change) }

  if new_ver.tiny2 < build
    new_ver.change(tiny2: build)
  else
    new_ver
  end
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
  ver[:build]  = version.tiny2
  
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
      desc "Bump version to #{bump_version(VERSION, field => true).to_s}"
      task field do
        save_version(bump_version(VERSION, field => true))
      end
    end
  end
  
  desc "Release version #{VERSION.release.to_s}"
  task :release do
    save_version(VERSION.release)
  end
  
  desc "Prepare for release #{bump_version(VERSION, minor: true, release_type: :beta).to_s}"
  task :pre do
    save_version(bump_version(VERSION, minor: true, release_type: :beta))
  end
  
  namespace :pre do
    VERSION.field_names[0..2].each do |field|
      desc "Prepare for release #{bump_version(VERSION, field => true, release_type: :beta).to_s}"
      task field do
        save_version(bump_version(VERSION, field => true, release_type: :beta))
      end
    end
  end
end
