class RankingController < ApplicationController
    
    def have
        ids = Have.group(:item_id).order('count_item_id desc').limit(10).count(:item_id).keys
        @items = Item.find(ids).sort_by do |o|
            ids.index(o.id)
        end
        render 'have'
        
    end
    
    def want
        ids = Want.group(:item_id).order('count_item_id desc').limit(10).count(:item_id).keys
        @items = Item.find(ids).sort_by do |o|
            ids.index(o.id)
        end
        render 'want'
    end
    
end
