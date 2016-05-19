class Aba
  class Batch
    class Transactions
      def initialize
        @collection = Array.new
      end

      def add_transaction(transaction)
        @collection.push(transaction)
      end

      def count
        return @collection.count
      end

      def valid?
        return !@collection.map(&:valid?).include?(false)
      end

      def validate!
        if @collection.empty?
          raise RuntimeError, 'No transactions present - add one using #add_transaction method'
        end

        unless valid?
          raise RuntimeError, 'Some transactions are invalid - check output of #errors method for more information'
        end
      end

      def error_collection
        errors = @collection.each_with_index.map{ |t, i| [i, t.errors] }
        errors = errors.reject{ |e| e[1].nil? || e[1].empty? }
        errors = errors.to_h

        return errors
      end
      alias_method :errors, :error_collection

      def to_s
        validate!

        return @collection.map(&:to_s).join("\r\n")
      end
    end
  end
end
