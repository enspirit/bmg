module Bmg
  class Database
    class DataFolder < Database

      DEFAULT_OPTIONS = {
        data_extensions: ['json', 'yml', 'yaml', 'csv'],
        relname_from_file: ->(file) { file.basename.rm_ext.to_sym },
      }

      def initialize(folder, options = {})
        @folder = Path(folder)
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def method_missing(name, *args, &bl)
        return super(name, *args, &bl) unless args.empty? && bl.nil?
        raise NotSuchRelationError(name.to_s) unless file = find_file(name)
        read_file(file)
      end

      def each_relation_pair
        return to_enum(:each_relation_pair) unless block_given?

        @folder.glob('*') do |path|
          next unless path.file?
          next unless @options[:data_extensions].find {|ext|
            path.ext == ".#{ext}" || path.ext == ext
          }
          yield(@options[:relname_from_file].call(path), read_file(path))
        end
      end

      def self.dump(database, path, ext = :json)
        path = Path(path)
        path.mkdir_p
        database.each_relation_pair do |name, rel|
          if ext === :json
            (path/"#{name}.#{ext}").write(JSON.pretty_generate(rel))
          else
            (path/"#{name}.#{ext}").write(rel.public_send(:"to_#{ext}"))
          end
        end
        path
      end

    private

      def read_file(file)
        case file.ext.to_s
        when '.json'
          Bmg.json(file)
        when '.yaml', '.yml'
          Bmg.yaml(file)
        when '.csv'
          Bmg.csv(file)
        else
          raise NotSupportedError, "Unable to use #{file} as a relation"
        end
      end

      def find_file(name)
        exts = @options[:data_extensions]
        exts.each do |ext|
          target = @folder.glob("*#{name}.#{ext}")
          return target.first if target&.first&.file?
        end
        raise NotSuchRelationError, "#{@folder}/#{name}.#{exts.join(',')}"
      end

    end # class DataFolder
  end # class Database
end # module Bmg
