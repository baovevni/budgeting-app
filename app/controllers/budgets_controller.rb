class BudgetsController < ApplicationController
  before_action :set_budget, only: %i[show edit update destroy]

  # GET /budgets or /budgets.json
  def index
    if params[:archive_month]
      # Fetch budgets for the selected archive month
      @budget_categories = Budget.includes(:category)
                                 .where(archive_month: Date.parse(params[:archive_month]), current_month: false)
                                 .map do |budget|
        {
          category: budget.category.name,
          budget_amount: budget.budget_amount.to_f,
          fact_amount: budget.fact_amount.to_f,
          budget_id: budget.id,
          archive_month: true
        }
      end
    else
      # Fetch the current month's budget
      @budget_categories = Budget.includes(:category)
                                 .where(current_month: true)
                                 .map do |budget|
        {
          category: budget.category.try(:name),
          category: budget.category.name,
          budget_amount: budget.budget_amount.to_f,
          fact_amount: budget.fact_amount.to_f,
          budget_id: budget.id,
          archive_month: false
        }
      end
    end

    @archive_months = Budget.distinct.pluck(:archive_month).compact.sort.reverse.reject { |month| month == Date.today.beginning_of_month }
    @budget = Budget.new
  end

  # GET /budgets/1 or /budgets/1.json
  def show
  end

  # GET /budgets/new
  def new
    @budget = Budget.new
  end

  # GET /budgets/1/edit
  def edit
  end

  # POST /budgets or /budgets.json
  def create
    category = Category.find_or_create_by(name: budget_params[:category_name])
    
    @budget = Budget.find_or_initialize_by(category: category, current_month: true)
    @budget.assign_attributes(budget_params.except(:category_name).merge(category: category, budget_amount_cents: budget_params[:budget_amount_cents].to_i * 100,
    fact_amount_cents: 0, current_month: true))

    respond_to do |format|
      if @budget.save
        format.html { redirect_to budgets_url, notice: "Category added." }
        format.json { render :show, status: :created, location: @budget }
      else
        format.html { render :index, status: :unprocessable_entity } # Render index on error
        format.json { render json: @budget.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /budgets/1 or /budgets/1.json
  def update
    respond_to do |format|
      if @budget.update(budget_params)
        format.html { redirect_to budgets_url, notice: "Budget category was successfully updated." }
        format.json { render :show, status: :ok, location: @budget }
      else
        format.html { render :edit, status: :unprocessable_entity } # Render edit on error
        format.json { render json: @budget.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /budgets/1 or /budgets/1.json
  def destroy
    @budget.destroy
    respond_to do |format|
      format.html { redirect_to budgets_url, notice: "Budget was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_budget
    @budget = Budget.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def budget_params
    params.require(:budget).permit(:category_name, :budget_amount_cents)
  end
end
