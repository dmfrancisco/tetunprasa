class EntriesController < ApplicationController
  def index
    if params[:buka].present?
      search
    else
      browse
    end
  end

  private

  def search
    @results = Entry.solr_search do
      fulltext params[:buka]
      group(:name_for_group) { limit 20 } # Up to 20 homonyms should be more than sufficient
    end
  end

  def browse
    @results = Entry.solr_search do
      with :letter, (params[:letter] || 'A').upcase
      order_by :name_for_order
      group(:name_for_group) { limit 20 }
      with :is_subentry, false # Only show top level entries
    end
  end
end
