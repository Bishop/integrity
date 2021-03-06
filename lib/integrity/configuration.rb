module Integrity
  class Configuration
    attr_reader :directory,
      :base_url,
      :builder

    attr_accessor :build_all,
      :auto_branch,
      :github_token,
      :log,
      :username,
      :password,
      :project_default_build_count,
      :trim_branches,
      :build_output_interval,
      :checkout_proc,
      :status_image_always_public

    def build_all?
      !! @build_all
    end

    def status_image_always_public?
      !! @status_image_always_public
    end

    def auto_branch?
      !! @auto_branch
    end

    def github_enabled?
      !! @github_token
    end

    def trim_branches?
      !! @trim_branches
    end

    def protected?
      @username && @password
    end

    def log_dir
      @log_dir ||= File.join(File.dirname(__FILE__),  '..', '..', 'log')
    end

    def log_file
      @log_file ||= File.join(log_dir, @log) if @log
    end

    def logger
      @logger ||= Logger.new(log_file)
    end

    def database=(uri)
      DataMapper.setup(:default, uri)
    end

    def directory=(dir)
      @directory = Pathname(dir)
    end

    def base_url=(url)
      @base_url = Addressable::URI.parse(url)
    end

    def builder=(builder)
      name, args = builder

      @builder =
        case name
        when :threaded
          Integrity::ThreadedBuilder.new(args || 2, logger)
        when :dj
          Integrity::DelayedBuilder.new(args)
        when :resque
          Integrity::ResqueBuilder
        when :explicit
          Integrity::ExplicitBuilder.new
        else
          raise ArgumentError, "Unknown builder #{name}"
        end
    end

    def notifiers=(notifiers)
      notifiers.each do |notifier|
        Integrity::Notifier.register(notifier)
      end
    rescue NameError => e
      raise ArgumentError, "Unknown notifier #{e.name}"
    end
  end
end
