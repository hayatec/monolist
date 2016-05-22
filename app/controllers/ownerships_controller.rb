class OwnershipsController < ApplicationController
  before_action :logged_in_user

  def create
    if params[:asin]
      @item = Item.find_or_initialize_by(asin: params[:asin])
    else
      @item = Item.find(params[:item_id])
    end
    
    # itemsテーブルに存在しない場合はAmazonのデータを登録する。
    if @item.new_record?
      begin
        # TODO 商品情報の取得 Amazon::Ecs.item_lookupを用いてください
        asin = params[:asin]
        response = Amazon::Ecs.item_lookup(asin, :ResponseGroup => 'Medium', :country => 'jp')
      rescue Amazon::RequestError => e
        return render :js => "alert('#{e.message}')"
      end

      amazon_item       = response.items.first
      @item.title        = amazon_item.get('ItemAttributes/Title')
      @item.small_image  = amazon_item.get("SmallImage/URL")
      @item.medium_image = amazon_item.get("MediumImage/URL")
      @item.large_image  = amazon_item.get("LargeImage/URL")
      @item.detail_page_url = amazon_item.get("DetailPageURL")
      @item.raw_info        = amazon_item.get_hash
      @item.save!
    end
    
    # TODO ユーザにwant or haveを設定する
    # params[:type]の値にHaveボタンが押された時には「Have」,
    # Wantボタンが押された時には「Want」が設定されています。
    
    type =  params[:type]

    ## type がWantの場合
    if type == "Want"
      #binding.pry
      current_user.want(user_id: current_user.id, item_id: @item.id, type: type) 
    end
      
    ## type がHaveの場合
    if type == "Have"
      #binding.pry
      current_user.have(user_id: current_user.id, item_id: @item.id, type: type) 
      
    end
    
     @amazon_items = @item

  end
  
  def destroy
    @item = Item.find(params[:item_id])
    type =  params[:type]

    # TODO 紐付けの解除。 
    # params[:type]の値にHave itボタンが押された時には「Have」,
    # Want itボタンが押された時には「Want」が設定されています。

    ## type がWantの場合
    if type == "Want"
      #binding.pry
      current_user.unwant(@item) 
    end
      
    ## type がHaveの場合
    if type == "Have"
      #binding.pry
      current_user.unhave(@item) 
    end


  end

end
