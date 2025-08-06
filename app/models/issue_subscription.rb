class IssueSubscription < ActiveRecord::Base
  belongs_to :issue
  belongs_to :user

  validates :issue_id, presence: true
  validates :user_id, presence: true
  validates :user_id, uniqueness: { scope: :issue_id, message: :already_subscribed }

  scope :for_issue, ->(issue) { where(issue_id: issue.id) }
  scope :for_user, ->(user) { where(user_id: user.id) }
end 