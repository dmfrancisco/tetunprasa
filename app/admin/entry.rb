ActiveAdmin.register Entry do
  actions :index, :edit, :update

  config.sort_order = 'id_asc'

  config.clear_sidebar_sections!

  scope :all, default: true
  scope "With duplicate portuguese words", :with_duplicate_pt_words
  scope "Manually updated", :manually_updated

  permit_params :glossary_pt

  index do
    column "Term" do |resource|
      resource.term.name
    end
    column "Glossary (english)" do |resource|
      resource.glossary_en.to_s.html_safe
    end
    column "Glossary (portuguese)" do |resource|
      resource.glossary_pt.to_s.html_safe
    end
    column "Info (english)" do |resource|
      resource.info_en.to_s.html_safe
    end
    column "Info (portuguese)" do |resource|
      resource.info_pt.to_s.html_safe
    end

    column do |resource|
      link_to "View english", root_path(buka: resource.term.name), target: "_blank"
    end
    column do |resource|
      link_to "View portuguese", root_path(locale: :pt, buka: resource.term.name), target: "_blank"
    end

    actions
  end

  form do |f|
    columns do
      column span: 2 do
        f.inputs "Glossary and additional information" do
          f.input :term, as: :string,
            input_html: { readonly: true, disabled: true, value: resource.term.name }

          f.input :glossary_en,
            input_html: { rows: 5, readonly: true, disabled: true },
            label: "Glossary (english)"

          f.input :glossary_pt,
            input_html: { rows: 5 },
            label: "Glossary (portuguese)"

          f.input :info_en,
            input_html: { rows: 3, readonly: true, disabled: true },
            label: "Info (english)"

          f.input :info_pt,
            input_html: { rows: 3, readonly: true, disabled: true },
            label: "Info (portuguese)"
        end

        f.actions
      end

      column do
        panel "Details" do
          attributes_table_for entry do
            row "Usage" do |resource|
              resource.usage.to_a.join("; ")
            end
            row "Part of speech" do |resource|
              resource.part_of_speech.to_a.join("; ")
            end

            row "Variants" do |resource|
              resource.variants.to_a.join("; ")
            end
            row "Male counterpart" do |resource|
              resource.male_counterpart.to_a.join("; ")
            end
            row "Female counterpart" do |resource|
              resource.female_counterpart.to_a.join("; ")
            end
            row "Counterpart" do |resource|
              resource.counterpart.to_a.join("; ")
            end
            row "Antonyms" do |resource|
              resource.antonyms.to_a.join("; ")
            end
            row "Synonyms" do |resource|
              resource.synonyms.to_a.join("; ")
            end
            row "Cross references" do |resource|
              resource.cross_references.to_a.join("; ")
            end
            row "Similar" do |resource|
              resource.similar.to_a.join("; ")
            end
            row "Origin" do |resource|
              resource.origin.to_a.join("; ")
            end
            row "Categories" do |resource|
              resource.categories.to_a.join("; ")
            end
          end
        end
      end

      column do
        panel 'Metadata' do
          attributes_table_for entry do
            row "Has duplicate portuguese words" do |resource|
              status_tag resource.has_duplicate_pt_words
            end
          end
        end

        panel "Attributes" do
          attributes_table_for entry do
            row "ID" do
              resource.id
            end
            row "Personal ID" do
              resource.pid
            end
            row "Parent ID" do
              resource.parent_id
            end
          end
        end
      end
    end
  end

  action_item :view_english, only: :edit do
    link_to "View english", root_path(buka: resource.term.name), target: "_blank"
  end

  action_item :view_portuguese, only: :edit do
    link_to "View portuguese", root_path(locale: :pt, buka: resource.term.name), target: "_blank"
  end

  controller do
    def update
      # Track who did this manual update
      resource.updated_by = current_admin_user.email

      # Jump to another entry that may need fixing
      next_resource = Entry
        .where("metadata->>'has_duplicate_pt_words' = ?", 'true')
        .order("random()").first

      update! do |format|
        format.html { redirect_to edit_admin_entry_path(next_resource) }
      end
    end
  end
end
