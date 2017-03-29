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
      terms: params[:buka].present? ? search : browse,
      related: params[:konsulta].present? ? related : nil,
      examples: params[:buka].present? ? search_examples : intro_examples
    }
  end

  def search
    Term.solr_search(include: { entries: [:subentries, :examples] }) do
      fulltext clean_search_query(params[:buka])
      order_by :score, :desc
      order_by :name_for_order, :asc
      paginate page: params[:page], per_page: Term::PER_PAGE
    end
  end

  def browse
    Term.solr_search(include: { entries: [:subentries, :examples] }) do
      with :letter, active_letter
      order_by :name_for_order, :asc
      with :is_subentry, false # Only show top level entries
      paginate page: params[:page], per_page: Term::PER_PAGE
    end
  end

  def related
    Term.solr_search(include: { entries: [:subentries, :examples] }) do
      with :name, Entry.related_from_ref(params[:konsulta])
      order_by :name_for_order, :asc
      paginate page: 1, per_page: 50 # Should be sufficient to show all
    end
  end

  def search_examples
    Example.solr_search do
      fulltext clean_search_query(params[:buka])
      paginate page: 1, per_page: 5 # Show the 5 most relevant
    end
  end

  def intro_examples
    Example.solr_search do
      order_by :random
      paginate page: 1, per_page: 5
    end
  end

  def permitted_params
    params.permit(:anchor, :letra, :buka, :konsulta)
  end

  def active_letter
    Term::ALPHABET.include?(params[:letra]) ? params[:letra] : 'A'
  end

  def clean_search_query(query)
    query.gsub("?", "")
  end
end
