class EntriesController < ApplicationController
  helper_method :permitted_params
  helper_method :active_letter

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
      related: params[:konsulta].present? ? related : nil,
      examples: params[:buka].present? ? search_examples : intro_examples
    }
  end

  def search
    Entry.solr_search do
      fulltext clean_search_query(params[:buka])
      group(:name) { limit 20 } # Up to 20 homonyms should be more than sufficient
      paginate page: params[:page], per_page: Entry::PER_PAGE
    end
  end

  def browse
    Entry.solr_search do
      with :letter, active_letter
      order_by :name_for_order
      group(:name) { limit 20 }
      with :is_subentry, false # Only show top level entries
      paginate page: params[:page], per_page: Entry::PER_PAGE
    end
  end

  def related
    Entry.solr_search do
      with :name, Entry.related_from_ref(params[:konsulta])
      group(:name) { limit 20 }
      paginate page: 1, per_page: 50 # Should be sufficient to show all
    end
  end

  def search_examples
    Example.solr_search do
      fulltext clean_search_query(params[:buka])
      paginate page: 1, per_page: 10 # Show the 10 most relevant
    end.results
  end

  def intro_examples
    Example.order("random()").limit(5)
  end

  def permitted_params
    params.permit(:anchor, :letra, :buka, :konsulta)
  end

  def active_letter
    Entry::ALPHABET.include?(params[:letra]) ? params[:letra] : 'A'
  end

  def clean_search_query(query)
    query.gsub("?", "")
  end
end
