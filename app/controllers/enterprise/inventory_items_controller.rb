module Enterprise
  class InventoryItemsController < Enterprise::BaseController
    before_action :set_item, only: %i[show edit update destroy]

    def index
      @items    = policy_scope(InventoryItem).ordered
      @by_cat   = @items.group_by(&:category)
      @low_stock = InventoryItem.low_stock.count
    end

    def show
      authorize @item
    end

    def new
      @item = InventoryItem.new
      authorize @item
    end

    def create
      @item = InventoryItem.new(item_params)
      authorize @item

      if @item.save
        redirect_to enterprise_inventory_item_path(@item), notice: "Item added to inventory."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @item
    end

    def update
      authorize @item

      if @item.update(item_params)
        redirect_to enterprise_inventory_item_path(@item), notice: "Item updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @item
      @item.destroy
      redirect_to enterprise_inventory_items_path, notice: "Item removed."
    end

    private

    def set_item
      @item = policy_scope(InventoryItem).find(params[:id])
    end

    def item_params
      params.require(:inventory_item).permit(
        :name, :description, :quantity, :condition,
        :category, :unit_value, :acquired_on, :location
      )
    end
  end
end
