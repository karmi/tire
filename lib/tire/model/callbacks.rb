module Tire
  module Model

    # Main module containing the infrastructure for automatic updating
    # of the _Elasticsearch_ index on model instance create, update or delete.
    #
    # Include it in your model: `include Tire::Model::Callbacks`
    #
    # The model must respond to `after_save` and `after_destroy` callbacks
    # (ActiveModel and ActiveRecord models do so, by default).
    #
    module Callbacks

      # A hook triggered by the `include Tire::Model::Callbacks` statement in the model.
      #
      def self.included(base)

        # Update index on model instance change or destroy.
        #
        if base.respond_to?(:after_save) && base.respond_to?(:after_destroy)
          base.send :after_save,    lambda { tire.update_index if should_save? }
          base.send :after_destroy, lambda { tire.update_index }
        end

				def should_save?
					if self.respond_to?(:changes) && self.class.should_tire_only_update_on_index_changes?
						unless defined? @indexed_properties
							raise "No tire index mapping has been defined for #{self.class.name}" if self.tire.index.mapping.nil?	
							@indexed_properties = self.tire.index.mapping[self.class.name.underscore]['properties'].keys
						end	
						(@indexed_properties & self.changes.keys).any?
					else
						return true
					end
				end

        # Add neccessary infrastructure for the model, when missing in
        # some half-baked ActiveModel implementations.
        #
        if base.respond_to?(:before_destroy) && !base.instance_methods.map(&:to_sym).include?(:destroyed?)
          base.class_eval do
            before_destroy  { @destroyed = true }
            def destroyed?; !!@destroyed; end
          end
        end

				base.extend(ClassMethods)
      end

			module ClassMethods
				def should_tire_only_update_on_index_changes(should_change = false)
					@should_tire_only_update_on_index_changes = should_change
				end

				def should_tire_only_update_on_index_changes?
					@should_tire_only_update_on_index_changes ||= false
				end
			end

    end

  end
end
