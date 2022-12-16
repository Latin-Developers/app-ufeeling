# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

module UFeeling
  # Web App
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    plugin :caching
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :public, root: 'app/presentation/public'
    plugin :assets, path: 'app/presentation/assets', css: 'style.css'
    plugin :common_logger, $stderr

    use Rack::MethodOverride

    route do |routing|
      routing.assets # load CSS
      response['Content-Type'] = 'text/html; charset=utf-8'
      routing.public
      # [GET]   /                             Home
      # [POST]  /videos?url=                  Analyze a new video
      # [GET]   /videos/:video_id             Gets the analysis of a video
      # [GET]   /videos/:video_id/comments    Gets the analysis of a video including the list of top comments

      # [GET] /
      routing.root do
        # Get cookie viewer's previously seen videos
        session[:watching] ||= []

        # Load previously searched videos
        # videos = UFeeling::Videos::Repository::For.klass(UFeeling::Videos::Entity::Video)
        # .find_ids(session[:watching])
        result = Services::HomePage.new.call(video_ids: session[:watching])

        if result.failure?
          flash[:error] = result.failure
          viewable_videos = []
        else
          videos = result.value![:videos].videos
          flash.now[:notice] = 'Add a Youtube video to get started' if videos.none?

          # session[:watching] = videos.map(&:origin_id)
          viewable_videos = Views::VideoList.new(videos)
        end

        view 'home', locals: { videos: viewable_videos }

        # Intenté pero no funcionó ):

        # result = Services::HomePage.new.call(categories_json:)
        # categories = result.value![:categories].categories
        # viewable_categories = Views::CategoryList.new(categories)

        # view 'home', locals: { categories: viewable_categories }
      end

      # [...] /videos/
      routing.on 'videos' do
        routing.is do
          # [POST]  /videos?url=
          routing.post do
            url_request = Forms::NewVideo.new.call(routing.params)
            new_video = Services::AddVideo.new.call(url_request)

            if new_video.failure?
              flash[:error] = new_video.failure
              routing.redirect '/'
            end

            video = new_video.value!
            session[:watching].insert(0, video.origin_id).uniq!
            flash[:notice] = 'New video added'
            routing.redirect "videos/#{video.origin_id}"
          end
        end

        # [...]  /videos/:video_origin_id
        routing.on String do |video_origin_id|
          # [GET]  /videos/:video_origin_id
          routing.is do
            routing.get do
              # Get Video from database
              video_result = Services::GetVideo.new.call(video_id: video_origin_id)

              if video_result.failure?
                flash[:error] = video_result.failure
                routing.redirect '/'
              end

              video_info = Views::VideoInfo.new(video_result.value!, [])

              # Setting Cache headers for Proxy and Browser
              # ? Deberiamos crear un helper para dejar el(los) tiempo(s) de Cache en una constante?
              App.configure :production do
                response.expires 120, public: true
              end

              # Show viewer the video
              view 'video', locals: { video_info: }
            end
          end

          # [...]  /videos/:video_origin_id/comments
          routing.on 'comments' do
            # [GET]  /videos/:video_origin_id/comments
            # routing.get {}
          end
        end
      end
    end
  end
end
