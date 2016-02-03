require_relative 'google_auth'

class Inbox
  def message_count_for_query(query)
    messages_for_query(query).result_size_estimate
  end

private
  def messages_for_query(query)
    service.list_user_messages('me', q: query)
  end

  def service
    GoogleAuth.service
  end
end
