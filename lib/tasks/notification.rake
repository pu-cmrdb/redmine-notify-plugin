namespace :redmine_notify_plugin do
  desc 'Check issues and send due date notifications'
  task notify_due_dates: :environment do
    Rails.logger.info 'Starting daily due date notification check...'

    begin
      require_dependency File.expand_path('../../issue_patch', __FILE__)
      
      notification_days = Setting.plugin_redmine_notify_plugin['notification_days_before'].to_i
      
      # 如果電子郵件通知已關閉，則跳過
      unless Setting.plugin_redmine_notify_plugin['enable_email_notifications']
        Rails.logger.info 'Email notifications are disabled. Skipping...'
        next
      end

      due_date = Date.today + notification_days.days
      issues = Issue.joins(:issue_subscriptions)
                   .where(due_date: due_date)
                   .includes(:subscribers)
                   .distinct

      Rails.logger.info "Found #{issues.count} issues due in #{notification_days} days"

      issues.each do |issue|
        Rails.logger.info "Processing notifications for Issue ##{issue.id} (due: #{issue.due_date})"
        issue.notify_subscribers
      end

    rescue StandardError => e
      Rails.logger.error "Error during notification check: #{e.message}\n#{e.backtrace.join("\n")}"
    end

    Rails.logger.info 'Completed daily due date notification check'
  end
end