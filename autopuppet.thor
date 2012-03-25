require 'open3'
require 'yaml'

begin 
  require 'thor'
rescue LoadError
  require 'rubygems'
  require 'thor'
end


# Class name isn't puppet to avoid namespace clashing.
class AutoPuppet < Thor
  namespace :puppet

  desc "config", "Generate your ~/.autopuppet"
  def config

    @@configfile = "#{ENV['HOME']}/.autopuppet"

    if File.exist? @@configfile
      @@config = YAML.load(File.read(@@configfile))
    else
      say "~/.autopuppet does not exist", :yellow

      @@config = {"deploy" => {}, "agent" => {}}
      @@config["deploy"]["master"] = ask "Puppet master:"
      @@config["deploy"]["command"] = ask "Command to execute:"

      File.open(@@configfile, "w") do |file|
        file.write YAML.dump @@config
      end
    end
  end

  desc "deploy", "Run puppet deployment on master"
  method_option :env, :type => :string, :aliases => "-e"
  def deploy
    invoke "puppet:config"

    say "Running #{@@config["deploy"]["command"]} on #{@@config["deploy"]["master"]}"

    cmd = %{ssh -T #{@@config["deploy"]["master"]} "#{@@config["deploy"]["command"]}"}
    Open3.popen3(cmd) do |input, output, err, thr|

      while thr.alive?
        handles = [output, err]
        readable, writable, errable = Kernel.select(handles, [], [], 1)

        readable.each do |io|
          print io.getc unless io.eof?
          $stdout.flush
        end unless readable.nil?
      end
    end

    puts
    say "Done!", :green
  end

  desc "hotrun [HOST]", "Deploy changes and run agent updates"
  method_option :env, :type => :string, :aliases => "-e"
  method_option :noop, :type => :boolean, :aliases => "-n"
  def hotrun(*hosts)
    invoke "puppet:deploy", []
    invoke "puppet:agent"
  end

  desc "agent [HOST]", "Update the server and run puppet on a host"
  method_option :env, :type => :string, :aliases => "-e"
  method_option :noop, :type => :boolean, :aliases => "-n"
  def agent(*hosts)
    invoke "puppet:config", []
    hosts.each do |host|
      cmd = "sudo puppet agent --onetime"
      cmd << " --environment #{options[:env]}" if options[:env]
      cmd << " --noop" if options[:noop]

      if @@config["agent"]["args"].size > 0
        cmd << " #{@@config["agent"]["args"].join(" ")}"
      end

      say "Executing #{cmd} on #{host}"

      ssh_cmd = %Q{ssh #{host} "#{cmd}"}
      Open3.popen3(ssh_cmd) do |input, output, err, thr|

        while thr.alive?
          handles = [output, err]
          readable, writable, errable = Kernel.select(handles, [], [], 1)

          readable.each do |io|
            print io.getc unless io.eof?
            $stdout.flush
          end unless readable.nil?
        end
      end
    end
  end
end
