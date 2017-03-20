class EntriesController < ApplicationController
  helper_method :permitted_params

  def index
    respond_to do |format|
      format.html { render :index, locals: data }
      format.js { render :index, locals: data }
    end
  end

  private

  def data
    {
      results: params[:buka].present? ? search : browse,
      related: params[:konsulta].present? ? related : nil
    }
  end

  def search
    Entry.solr_search do
      fulltext params[:buka]
      group(:name) { limit 20 } # Up to 20 homonyms should be more than sufficient
      paginate page: 1, per_page: 50
    end
  end

  def browse
    Entry.solr_search do
      with :letter, Entry::ALPHABET.include?(params[:letra]) ? params[:letra] : 'A'
      order_by :name_for_order
      group(:name) { limit 20 }
      with :is_subentry, false # Only show top level entries
      paginate page: params[:page], per_page: 50
    end
  end

  def related
    Entry.solr_search do
      with :name, Entry.related_from_ref(params[:konsulta])
      group(:name) { limit 20 }
      paginate page: 1, per_page: 50
    end
  end

  def permitted_params
    params.permit(:anchor, :letra, :buka, :konsulta)
  end
end
