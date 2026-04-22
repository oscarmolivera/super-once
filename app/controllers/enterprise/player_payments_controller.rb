module Enterprise
  class PlayerPaymentsController < Enterprise::BaseController
    before_action :set_payment, only: %i[show edit update destroy mark_paid]

    def index
      @month = (params[:month] || Date.current.month).to_i
      @year  = (params[:year]  || Date.current.year).to_i

      @payments       = policy_scope(PlayerPayment)
        .where(month: @month, year: @year)
        .recent
      @total_expected = @payments.sum(:amount)
      @total_paid     = @payments.paid.sum(:amount)
      @total_pending  = @payments.pending.sum(:amount)
      @total_overdue  = @payments.overdue.sum(:amount)
    end

    def show
      authorize @payment
    end

    def new
      @payment = PlayerPayment.new(
        month:  Date.current.month,
        year:   Date.current.year,
        due_on: Date.current.end_of_month
      )
      authorize @payment
    end

    def create
      @payment = PlayerPayment.new(payment_params)
      authorize @payment

      if @payment.save
        redirect_to enterprise_player_payments_path,
          notice: "Payment entry created for #{@payment.player_name}."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @payment
    end

    def update
      authorize @payment

      if @payment.update(payment_params)
        redirect_to enterprise_player_payments_path, notice: "Payment updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @payment
      @payment.destroy
      redirect_to enterprise_player_payments_path, notice: "Payment entry removed."
    end

    # PATCH /enterprise/player_payments/:id/mark_paid
    def mark_paid
      authorize @payment, :update?
      @payment.mark_paid!
      redirect_back_or_to enterprise_player_payments_path,
        notice: "#{@payment.player_name} marked as paid."
    end

    private

    def set_payment
      @payment = policy_scope(PlayerPayment).find(params[:id])
    end

    def payment_params
      params.require(:player_payment).permit(
        :player_name, :amount, :due_on, :paid_on,
        :month, :year, :status, :notes
      )
    end
  end
end
