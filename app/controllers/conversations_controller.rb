class ConversationsController < ApplicationController
  before_action :get_mailbox
  before_action :get_conversation, except: [:index, :empty_trash]
  before_action :get_box, only: [:index]

  def index
    if @box.eql? "inbox"
      @conversations = @mailbox.inbox
    elsif @box.eql? "sent"
      @conversations = @mailbox.sentbox
    else
      @conversations = @mailbox.trash
    end

    @conversations = @conversations.paginate(page: params[:page], per_page: 10)
  end

  def show
    @conversation.mark_as_read(current_user)
  end

  def reply
    current_user.reply_to_conversation(@conversation, params[:body])
    flash[:success] = I18n.t('conversations.reply.success')
    redirect_to conversation_path(@conversation)  
  end

  def destroy
    @conversation.move_to_trash(current_user)
    flash[:success] = I18n.t('conversations.destroy.success')
    redirect_to conversations_path
  end

  def restore
    @conversation.untrash(current_user)
    flash[:success] = I18n.t('conversations.restore.success')
    redirect_to conversations_path
  end

  def empty_trash
    @mailbox.trash.each do |conversation|
      conversation.receipts_for(current_user).update_all(delete: true) 
    end   
    flash[:success] = I18n.t('conversations.empty_trash.success') 
    redirect_to conversations_path
  end

  private
  def get_box
    if params[:box].blank? or !["inbox","sent","trash"].include?(params[:box])
      params[:box] = 'inbox'
    end
    @box = params[:box]
  end

  def get_mailbox
    @mailbox ||= current_user.mailbox
  end

  def get_conversation
    @conversation ||= @mailbox.conversations.find(params[:id])
  end

end  