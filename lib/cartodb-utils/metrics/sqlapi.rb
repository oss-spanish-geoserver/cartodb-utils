module CartoDBUtils
  module Metrics
  
    class SQLAPI

      SQLAPI_PATH = "/api/v1/sql" 
      
      EVENT_AGGREGATION_TEMPLATE = <<-EOS
      WITH upsert AS (
        UPDATE events 
        SET value=##VALUE##
        WHERE timestamp='##TIMESTAMP##'
        AND tags='##TAGS##' 
        RETURNING *
      )
      INSERT INTO events (timestamp, value, tags) 
        SELECT '##TIMESTAMP##', ##VALUE##, '##TAGS##' 
        WHERE NOT EXISTS (SELECT * FROM upsert);
      EOS

      def initialize(options = {})
        @api_key = options[:api_key]
        @cartodb_domain = options[:cartodb_domain]
        @sqlapi_url = "https://#{@cartodb_domain}#{SQLAPI_PATH}?api_key=#{@api_key}"
      end

      def request(sql_query)
        response_code, body = CartoDBUtils.http_request(@sqlapi_url, 1, {:params => {:q => sql_query}, :http_method => :post}) 
        return body
      end

    end
  end
end
