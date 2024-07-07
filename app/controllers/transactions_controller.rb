class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ edit update destroy ]

  # GET /transactions or /transactions.json
  def index
    if params[:search].present?
      # where("name like ?", "%#{params[:search]}%").first
      amount_in_cents = "@"
      if params[:search].to_money.fractional > 0
        amount_in_cents = params[:search].to_money.fractional
      end
        @transactions = 
          Transaction.joins(:category, :account)
            .where("categories.name LIKE ? OR accounts.name LIKE ? OR amount_cents LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%", "%#{amount_in_cents}%")
            .order(date: :desc)
    else
      @transactions = Transaction.all.order(date: :desc)
    end
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit
  end

  # POST /transactions or /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to [:transactions], notice: "Transaction was successfully created." }
        format.json { render :show, status: :created, location: @transaction }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transactions/1 or /transactions/1.json
  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to [:transactions], notice: "Transaction was successfully updated." }
        format.json { render :show, status: :ok, location: @transaction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1 or /transactions/1.json
  def destroy
    @transaction.destroy!

    respond_to do |format|
      format.html { redirect_to transactions_url, notice: "Transaction was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def transaction_params
      params.require(:transaction).permit(:date, :merchant, :amount, :category, :account_id, :category_id)
    end

end
