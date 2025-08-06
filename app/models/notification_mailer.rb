class NotificationMailer < Mailer
  def notify_due_date(issue, user)
    return unless issue.due_date  # 沒有到期日
    return unless user&.mail      # 沒有電子郵件

    @issue = issue
    @user = user
    @days_left = (issue.due_date - Date.today).to_i

    # 只有天數符合設定時才發送通知
    notification_days = Setting.plugin_redmine_notify_plugin['notification_days_before'].to_i
    return unless @days_left == notification_days

    mail(to: user.mail,
         subject: l(:mail_subject_issue_due_date,
           days: @days_left,
           issue: "##{issue.id}",
           title: issue.subject))

  rescue StandardError => e
    Rails.logger.error "Failed to prepare notification email for Issue ##{issue.id} to #{user.mail}: #{e.message}"
    nil
  end
end 