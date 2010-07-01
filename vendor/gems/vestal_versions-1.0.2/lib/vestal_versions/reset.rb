module VestalVersions
  # Adds the ability to "reset" (or hard revert) a versioned ActiveRecord::Base instance.
  module Reset
    def self.included(base) # :nodoc:
      base.class_eval do
        include InstanceMethods
      end
    end

    # Adds the instance methods required to reset an object to a previous version.
    module InstanceMethods
      # Similar to +revert_to!+, the +reset_to!+ method reverts an object to a previous version,
      # only instead of creating a new record in the version history, +reset_to!+ deletes all of
      # the version history that occurs after the version reverted to.
      #
      # The action taken on each version record after the point of reversion is determined by the
      # <tt>:dependent</tt> option given to the +versioned+ method. See the +versioned+ method
      # documentation for more details.
      def reset_to!(value)
        if saved = skip_version{ revert_to!(value) }
          versions.send(:delete_records, versions.after(value))
          reset_version
        end
        saved
      end
    end
  end
end
