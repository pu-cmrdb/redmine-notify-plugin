class IssueSubscription < ActiveRecord::Base
  belongs_to :issue
  belongs_to :user

  validates :issue_id, presence: true
  validates :user_id, presence: true
  validates :user_id, uniqueness: { scope: :issue_id, message: :already_subscribed }

  scope :for_issue, ->(issue) { where(issue_id: issue.id) }
  scope :for_user, ->(user) { where(user_id: user.id) }

  # 檢查是否已經為特定到期日發送過通知
  def already_notified_for_due_date?(due_date)
    return false unless respond_to?(:last_notified_due_date) && respond_to?(:last_notification_sent_at)
    
    last_notified_due_date == due_date && last_notification_sent_at.present?
  end

  # 記錄通知發送
  def record_notification_sent!(due_date)
    unless respond_to?(:last_notification_sent_at) && respond_to?(:notification_count) && respond_to?(:last_notified_due_date)
      Rails.logger.warn "IssueSubscription ##{id} 缺少必要的通知追蹤欄位，請執行資料庫遷移"
      return false
    end
    
    update!(
      last_notification_sent_at: Time.current,
      notification_count: (notification_count || 0) + 1,
      last_notified_due_date: due_date
    )
  end

  # 重設通知狀態（當議題到期日改變時使用）
  def reset_notification_status!
    unless respond_to?(:last_notification_sent_at) && respond_to?(:notification_count) && respond_to?(:last_notified_due_date)
      Rails.logger.warn "IssueSubscription ##{id} 缺少必要的通知追蹤欄位，請執行資料庫遷移"
      return false
    end
    
    update!(
      last_notification_sent_at: nil,
      notification_count: 0,
      last_notified_due_date: nil
    )
  end
end 