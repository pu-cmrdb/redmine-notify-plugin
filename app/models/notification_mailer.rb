class NotificationMailer < Mailer
  def notify_due_date(user, issue)
    Rails.logger.info "準備通知議題 ##{issue.id} 給 #{user.mail}"

    unless issue.due_date
      Rails.logger.info "- ❌ 議題 ##{issue.id} 沒有到期日"
      return
    end

    unless user&.mail
      Rails.logger.info "- ❌ 使用者 #{user&.id} 沒有電子郵件"
      return 
    end

    @issue = issue
    @user = user
    @days_left = (issue.due_date - Date.today).to_i

    # 只有天數符合設定時才發送通知
    notification_days = Setting.plugin_redmine_notify_plugin['notification_days_before'].to_i
    Rails.logger.info "天數剩餘: #{@days_left}, 通知設定: #{notification_days}"
    
    unless @days_left == notification_days
      Rails.logger.info "跳過通知 - 天數不符 (#{@days_left} != #{notification_days})"
      return
    end

    Rails.logger.info "傳送通知電子郵件給議題 ##{issue.id} 給 #{user.mail} (#{@days_left} 天後到期)"

    mail(to: user.mail,
         subject: l(:mail_subject_issue_due_date,
           days: @days_left,
           issue: "##{issue.id}",
           title: issue.subject))

  rescue StandardError => e
    Rails.logger.error "準備通知電子郵件時發生錯誤: 議題 ##{issue.id} 給 #{user.mail}: #{e.message}"
    nil
  end
end 