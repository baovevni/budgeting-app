class AccountsController < ApplicationController
  before_action :set_account, only: %i[ show edit update destroy ]

  # GET /accounts or /accounts.json
  def index
    @accounts = Account.all
    @balanceCredit = Account.where(account_type: 'CREDIT').pluck(:current_balance_cents)
  end

  # GET /accounts/1 or /accounts/1.json
  def show
    @accounts = Account.all
    @account_transactions = Transaction.where(account_id: @account.id).order(date: :desc)
        # Transaction.where(account_id: params[:account_id])
  end

  # GET /accounts/new
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
  end

  #POST /accounts or /accounts.json
  def create
    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        format.html { redirect_to account_url(@account), notice: "Account was successfully created." }
        format.json { render :show, status: :created, location: @account }
        puts "saved"
      else
        format.html { render :new }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('modal', template: 'accounts/new', locals: { account: @account }) }
      
      end
    end
  end

  # PATCH/PUT /accounts/1 or /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to account_url(@account), notice: "Account was successfully updated." }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :new }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('modal', template: 'accounts/edit', locals: { account: @account }) }
      end
    end
  end

  # DELETE /accounts/1 or /accounts/1.json
  def destroy
    @account.destroy!

    respond_to do |format|
      format.html { redirect_to accounts_url, notice: "Account was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def account_params
      params.require(:account).permit(:name, :account_type, :current_balance)
    end
end
