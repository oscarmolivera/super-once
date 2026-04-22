module Enterprise
  class TaxPermitsController < Enterprise::BaseController
    before_action :set_permit, only: %i[show edit update destroy]

    def index
      @permits          = policy_scope(TaxPermit).ordered
      @expiring_soon    = TaxPermit.expiring_soon
      @expired          = TaxPermit.expired
    end

    def show
      authorize @permit
    end

    def new
      @permit = TaxPermit.new(status: :active)
      authorize @permit
    end

    def create
      @permit = TaxPermit.new(permit_params)
      authorize @permit

      if @permit.save
        redirect_to enterprise_tax_permit_path(@permit), notice: "Document added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @permit
    end

    def update
      authorize @permit

      if @permit.update(permit_params)
        redirect_to enterprise_tax_permit_path(@permit), notice: "Document updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @permit
      @permit.destroy
      redirect_to enterprise_tax_permits_path, notice: "Document removed."
    end

    private

    def set_permit
      @permit = policy_scope(TaxPermit).find(params[:id])
    end

    def permit_params
      params.require(:tax_permit).permit(
        :name, :document_type, :reference_number, :issued_on,
        :expires_on, :status, :issuing_authority, :notes
      )
    end
  end
end
