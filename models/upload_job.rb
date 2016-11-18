require "delayed_job"

class UploadJob < TransporterJob
  def after(job)
    return if account.notification.nil?
    Delayed::Job.enqueue(SendNotificationJob.new(id))
  end

  protected

  def typecast_options
    options[:rate]   = options[:rate].to_i if options[:rate] =~ /\A\d+\z/
    options[:delete] = to_bool(options[:delete])
    options[:batch]  = to_bool(options[:batch])
    true
  end

  def run
    optz = options.dup
    package = optz.delete(:package)
    itms.upload(package, optz)
  end

  def _target
     options[:package] ? File.basename(options[:package]) : super
  end
end
