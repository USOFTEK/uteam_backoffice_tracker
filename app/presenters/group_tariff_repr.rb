module Presenters
    module TariffPresenter
      include Roar::Representer::JSON
      include Roar::Representer::Feature::Hypermedia
      include Grape::Roar::Representer

      property :id
      property :name
      property :month_fee
      property :day_fee
      property :created_at

      # collection :entries, extend: GroupPresenter, as: :groups, embedded: true,
      #            getter: lambda { |args| self.groups if args[:with_groups] }
    end

    module TariffsPresenter
      include Roar::Representer::JSON
      include Roar::Representer::Feature::Hypermedia
      include Grape::Roar::Representer

      collection :entries, extend: TariffsPresenter, as: :tariffs, embedded: true
    end

    module GroupPresenter
      include Roar::Representer::JSON
      include Roar::Representer::Feature::Hypermedia
      include Grape::Roar::Representer

      property :id
      property :name
      property :description
      collection :entries, extend: TariffPresenter, as: :tariffs, embedded: true,
                 getter: lambda { |args| self.tariffs if args[:with_tariffs] }

    end

    module GroupsPresenter
      include Roar::Representer::JSON
      include Roar::Representer::Feature::Hypermedia
      include Grape::Roar::Representer

      collection :entries, extend: GroupPresenter, as: :groups, embedded: true
    end

  end
