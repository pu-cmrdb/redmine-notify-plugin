namespace :redmine_notify_plugin do
  desc '檢查議題到期並傳送通知'
  task notify_due_dates: :environment do
    Rails.logger.info '開始每日議題到期通知檢查...'

    begin
      require_dependency File.expand_path('../../issue_patch', __FILE__)
      
      notification_days = Setting.plugin_redmine_notify_plugin['notification_days_before'].to_i
      
      # 如果電子郵件通知已關閉，則跳過
      unless Setting.plugin_redmine_notify_plugin['enable_email_notifications']
        Rails.logger.info '電子郵件通知已關閉. 跳過...'
        next
      end

      due_date = Date.today + notification_days.days
      issues = Issue.joins(:issue_subscriptions)
                   .where('due_date <= ?', due_date)
                   .includes(:subscribers)
                   .distinct

      Rails.logger.info "有 #{issues.count} 個議題將在 #{notification_days} 天後到期"

      issues.each do |issue|
        Rails.logger.info "處理議題 ##{issue.id} (到期日: #{issue.due_date})"
        issue.notify_subscribers
      end

    rescue StandardError => e
      Rails.logger.error "處理議題通知時發生錯誤: #{e.message}\n#{e.backtrace.join("\n")}"
    end

    Rails.logger.info '完成每日議題到期通知檢查'
  end
end