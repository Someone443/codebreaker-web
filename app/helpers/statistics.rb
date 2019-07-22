class Statistics
  DB_PATH = 'db/results.yml'.freeze

  def self.load
    YAML.load_file(DB_PATH)
  rescue SystemCallError
    []
  end

  def self.save(data, response)
    results = self.load
    results << data

    File.write(DB_PATH, self.sorted(results).to_yaml)
    response.set_cookie('stats_saved', true)
  end

  def self.sorted(data)
    order = ["hell", "medium", "easy"]
    data.sort_by { |result| [order.index(result[:difficulty]), result[:attempts_used], result[:hints_used]] }
  end
end
