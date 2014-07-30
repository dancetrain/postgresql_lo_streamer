#encoding: utf-8

module PostgresqlLoStreamer
  class LoController < ActionController::Base
    def stream
      mime_type = Mime::Type.lookup_by_extension(request.original_url.split('.').last)
      ActiveRecord::Base.transaction do
        lo = lo_manager.java_send :open, [Java::long, Java::int], params[:id].to_i, Java::OrgPostgresqlLargeobject::LargeObjectManager::READ
        data = lo.read(lo.size)
        send_data data.to_s, type: mime_type, disposition: 'inline'
      end
    end

    private
    def connection
      @con ||= ActiveRecord::Base.connection.raw_connection
    end

    def lo_manager
      @lo_manager ||= connection.connection.getLargeObjectAPI
    end
  end
end
