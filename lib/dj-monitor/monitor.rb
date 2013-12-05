require 'sequel'
require 'pony'
module DjMonitor
  class Monitor

    class << self

      def run(options)
        Monitor.new(options).run
      end

      attr_accessor :default_table_name

    end

    DEFAULT_TABLE_NAME = "delayed_jobs".freeze

    self.default_table_name = DEFAULT_TABLE_NAME

    attr_reader :table_name

    DEFAULT_THRESHOLDS = {
      :total_job_threshold     => 50,
      :failed_job_threshold    => 1,
      :scheduled_job_threshold => 40,
      :waiting_job_threshold   => 10,
      :running_job_threshold   => 5
    }.freeze

    THRESHOLD_ATTRIBUTES = DEFAULT_THRESHOLDS.keys

    attr_accessor *THRESHOLD_ATTRIBUTES

    def initialize(options)
      @options    = options
      @db_options = @options[:database]
      @table_name = @db_options.delete(:table_name) { Monitor.default_table_name }

      # set thresholds, use default if not provided
      DEFAULT_THRESHOLDS.each do |attribute, threshold|
        send("#{attribute}=", options.delete(attribute) { threshold })
      end
    end

    def run
      if sick?
        alert
      end
    end

    def alert
      Pony.mail(:to      => @options[:alert_to] ? @options[:alert_to] : "dw@penthion.nl",
                :from    => @options[:alert_from] ? @options[:alert_from] : "monitor@penthion.nl",
                :subject => @options[:alert_subject] ? @options[:alert_subject] : "[Alert] DJ Queue (#{@db_options['database']})",
                :body    => alert_body)
    end

    def alert_body
      %Q{
  Delayed::Job Summary
  --------------------

  Total jobs:\t\t#{total_jobs}
  Failed jobs:\t\t#{failed_jobs}
  Scheduled jobs:\t#{scheduled_jobs}
  Waiting jobs:\t\t#{waiting_jobs}
  Running jobs:\t\t#{running_jobs}
          }
    end

    def sick?
      total_jobs >= total_job_threshold ||
        failed_jobs >= failed_job_threshold ||
        scheduled_jobs >= scheduled_job_threshold ||
        waiting_jobs >= waiting_job_threshold ||
        running_jobs >= running_job_threshold
    end

    def healthy?
      !sick?
    end

    def reset
      @total_jobs     = nil
      @scheduled_jobs = nil
      @waiting_jobs   = nil
      @running_jobs   = nil
      @failed_jobs    = nil
    end

    def total_jobs
      @total_jobs ||= count
    end

    def scheduled_jobs
      @scheduled_jobs ||= count(["run_at > ? AND locked_at IS NULL AND attempts = 0", Time.now])
    end

    def waiting_jobs
      @waiting_jobs ||= count(["run_at <= ? AND locked_at IS NULL AND attempts = 0", Time.now])
    end

    def running_jobs
      @running_jobs ||= count(["locked_at IS NOT NULL"])
    end

    def failed_jobs
      @failed_jobs ||= count(["(run_at > ? AND last_error IS NOT NULL) OR failed_at IS NOT NULL", Time.now])
    end

    def count(filter = nil)
      if filter
        delayed_jobs.filter(filter).count
      else
        delayed_jobs.count
      end
    end

    def delayed_jobs
      @delayed_jobs ||= database[table_name.to_sym]
    end

    def database
      @database ||= Sequel.connect(@db_options)
    end

  end
end